.pragma library

// One reusable native request per fixed polling channel. Completed callbacks
// are detached before invoking them, so a callback cannot retain old replies.
var slots = Object.create(null);
var allocated = 0;
var completed = 0;

function request(key, method, url, body, done) {
    var slot = slots[key];
    if (!slot) {
        if (allocated >= 20) throw new Error("Too many file request channels");
        slot = {xhr:new XMLHttpRequest(), busy:false, done:null};
        slots[key] = slot;
        allocated++;
        slot.xhr.onreadystatechange = function() {
            var current = slots[key];
            if (!current || current.xhr.readyState !== 4) return;
            var callback = current.done;
            var status = current.xhr.status;
            var text = current.xhr.responseText;
            current.done = null;
            current.busy = false;
            completed++;
            if (callback) callback(status, text);
        };
    }
    if (slot.busy) return false;
    slot.busy = true;
    slot.done = done || null;
    try {
        slot.xhr.open(method, url);
        if (method === "GET") slot.xhr.send(); else slot.xhr.send(body);
    } catch (error) {
        slot.done = null;
        slot.busy = false;
        throw error;
    }
    return true;
}
function read(key, url, done) { return request(key, "GET", url, null, done); }
function write(key, url, body, done) { return request(key, "PUT", url, body, done); }
function stats() {
    var busy = 0;
    for (var key in slots) if (slots[key].busy) busy++;
    return {allocated:allocated, busy:busy, completed:completed};
}
