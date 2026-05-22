import json, subprocess, threading, time
from queue import Queue

MCP = r"C:\Users\luthf\AppData\Local\Roblox\mcp.bat"

def run_mcp(calls, wait=2):
    p = subprocess.Popen([MCP], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, text=True, bufsize=1)
    qout, qerr = Queue(), Queue()
    def reader(stream, q):
        for line in stream:
            q.put(line.rstrip("\r\n"))
    threading.Thread(target=reader, args=(p.stdout, qout), daemon=True).start()
    threading.Thread(target=reader, args=(p.stderr, qerr), daemon=True).start()
    def send(obj):
        p.stdin.write(json.dumps(obj, separators=(",", ":")) + "\n")
        p.stdin.flush()
    send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{
        "protocolVersion":"2024-11-05","capabilities":{},
        "clientInfo":{"name":"get-logs","version":"1"}}})
    time.sleep(0.3)
    send({"jsonrpc":"2.0","method":"notifications/initialized","params":{}})
    time.sleep(0.2)
    for i, call in enumerate(calls, start=2):
        send({"jsonrpc":"2.0","id":i,"method":"tools/call","params":call})
        time.sleep(0.3)
    time.sleep(wait)
    out, err = [], []
    while not qout.empty():
        out.append(qout.get())
    while not qerr.empty():
        err.append(qerr.get())
    p.terminate()
    time.sleep(0.4)
    if p.poll() is None:
        p.kill()
    return out, err

calls = [{"name": "get_console_output", "arguments": {}}]
out, err = run_mcp(calls, wait=3)
messages = []
for line in out:
    try:
        obj = json.loads(line)
        if "result" in obj and "content" in obj["result"]:
            for item in obj["result"]["content"]:
                if item["type"] == "text":
                    messages.append(json.loads(item["text"]))
    except Exception as e:
        pass

print("=== ALL CONSOLE LOGS ===")
for msg in messages:
    print(f"[{msg.get('timestamp')}] {msg.get('message')}")
