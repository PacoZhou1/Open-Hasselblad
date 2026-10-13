"""Desktop stand-in for x2v_prr_play. Same /cmd /state /frame.ppm contract."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import threading
import time


class PlayState:
    def __init__(self, frames, fps=24.0, frame_path=None):
        self.lock = threading.Lock()
        self.frames = frames
        self.fps = fps
        self.frame_path = frame_path
        self.phase = 'idle'
        self.source = ''
        self.error = ''
        self.index = 0
        self.generation = 0
        self.started = 0.0

    @property
    def count(self):
        return len(self.frames)

    @property
    def duration(self):
        return self.count / self.fps if self.fps else 0

    @property
    def position(self):
        return self.index / self.fps if self.fps else 0

    def snapshot(self):
        w = h = 0
        if self.frames:
            w, h = self.frames[0][1], self.frames[0][2]
        return {
            'schema': 1,
            'phase': self.phase,
            'source': self.source,
            'index': self.index,
            'count': self.count,
            'width': w,
            'height': h,
            'position': round(self.position, 4),
            'duration': round(self.duration, 4),
            'generation': self.generation,
            'error': self.error,
        }

    def current_ppm(self):
        if not self.frames:
            return b''
        return self.frames[min(self.index, self.count - 1)][0]

    def apply(self, body):
        parts = body.strip().split(None, 1)
        if not parts:
            return
        op = parts[0]
        src = parts[1] if len(parts) > 1 else ''
        if op == 'open' and src:
            self.source = src
            self.error = ''
            self.index = 0
            self.generation += 1
            self.started = time.monotonic()
            self.phase = 'playing' if self.frames else 'error'
            if not self.frames:
                self.error = 'no fixture frames'
            self.write_frame()
        elif op == 'stop':
            self.phase = 'idle'
            self.source = ''
            self.error = ''
            self.index = 0
        elif op == 'pause' and self.phase == 'playing':
            self.phase = 'paused'
        elif op == 'resume' and self.phase == 'paused':
            self.phase = 'playing'
            self.started = time.monotonic() - (self.index / self.fps if self.fps else 0)

    def tick(self):
        if self.phase != 'playing' or not self.frames:
            return
        idx = int((time.monotonic() - self.started) * self.fps)
        if idx >= self.count:
            self.phase = 'ended'
            self.index = self.count - 1
            return
        if idx != self.index:
            self.index = idx
            self.generation += 1
            self.write_frame()

    def write_frame(self):
        if self.frame_path and self.frames:
            Path(self.frame_path).write_bytes(self.current_ppm())


def make_handler(state: PlayState):
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, fmt, *args):
            return

        def _send(self, code, ctype, body):
            data = body if isinstance(body, bytes) else body.encode()
            self.send_response(code)
            self.send_header('Content-Type', ctype)
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Connection', 'close')
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            self.wfile.write(data)

        def do_GET(self):
            try:
                with state.lock:
                    state.tick()
                    if self.path.startswith('/state'):
                        self._send(200, 'application/json', json.dumps(state.snapshot()) + '\n')
                        return
                    if self.path.startswith('/frame.ppm'):
                        ppm = state.current_ppm()
                        if not ppm:
                            self._send(404, 'text/plain', 'no\n')
                            return
                        self._send(200, 'image/x-portable-pixmap', ppm)
                        return
                self._send(404, 'text/plain', 'no\n')
            except BrokenPipeError:
                return

        def do_POST(self):
            length = int(self.headers.get('Content-Length') or 0)
            body = self.rfile.read(length).decode('utf-8', 'replace') if length else ''
            if self.path.startswith('/cmd'):
                with state.lock:
                    state.apply(body)
                self._send(200, 'text/plain', 'ok\n')
                return
            self._send(404, 'text/plain', 'no\n')

    return Handler


def start(frames, host='127.0.0.1', port=0, fps=24.0, frame_path=None):
    state = PlayState(frames, fps=fps, frame_path=frame_path)
    server = ThreadingHTTPServer((host, port), make_handler(state))
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server, state
