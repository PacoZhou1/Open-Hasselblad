.pragma library

// A mode write is refused while camera-service owns an AF exposure session.
// Pause through the existing AF context; apply once, then wait for native ack.
// No optimistic mode value and no delayed blind replay after a timeout.
function request(kind, value, snapshot, now) {
    return {kind: kind, value: value, deadline: now + 2500, applied: false,
            beforeMode: snapshot.mode, beforeSettings: snapshot.settings};
}

function step(command, snapshot, now) {
    if (!command) return {action: "none"};
    if (now >= command.deadline) return {action: "timeout"};
    if (snapshot.inSession || snapshot.exposing) return {action: "wait"};
    if (!command.applied) {
        command.applied = true;
        return {action: "apply", kind: command.kind, value: command.value};
    }
    var accepted = command.kind === "mode" ? snapshot.mode === command.value :
                   command.kind === "settings" ? snapshot.settings === command.value :
                   snapshot.mode !== command.beforeMode || snapshot.settings !== command.beforeSettings;
    return {action: accepted ? "done" : "wait"};
}
