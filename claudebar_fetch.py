#!/usr/bin/env python3
"""
Fetches Claude /usage data and writes to /tmp/claudebar-usage.json
"""
import pty, os, sys, re, time, json, select

OUTPUT_FILE = "/tmp/claudebar-usage.json"
CLAUDE_PATH = "/opt/homebrew/bin/claude"
DEBUG_FILE  = "/tmp/claudebar-debug.txt"

def get_usage():
    if not os.path.exists(CLAUDE_PATH):
        write_result(0, 0, "--", error="claude not found")
        return

    env = {
        "HOME": os.environ.get("HOME", os.path.expanduser("~")),
        "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin",
        "TERM": "xterm-256color",
        "CLAUDECODE": "",
        "LANG": "en_US.UTF-8",
    }

    master, slave = pty.openpty()

    pid = os.fork()
    if pid == 0:
        os.setsid()
        os.close(master)
        os.dup2(slave, 0)
        os.dup2(slave, 1)
        os.dup2(slave, 2)
        os.close(slave)
        home = env.get("HOME", os.path.expanduser("~"))
        trusted_dir = home
        os.chdir(trusted_dir)
        os.execvpe("/bin/bash", [
            "/bin/bash", "-c",
            f'cd "{trusted_dir}" && printf "/usage\\n" | {CLAUDE_PATH}; sleep 5'
        ], env)
        sys.exit(1)

    os.close(slave)
    output = b""
    deadline = time.time() + 20

    while time.time() < deadline:
        r, _, _ = select.select([master], [], [], 0.5)
        if r:
            try:
                chunk = os.read(master, 4096)
                output += chunk
            except OSError:
                break
        # Check for "% used" pattern (no space required)
        decoded = output.decode("utf-8", errors="ignore")
        if len(re.findall(r'\d+%\s*used', decoded)) >= 2:
            break

    try:
        os.waitpid(pid, os.WNOHANG)
    except Exception:
        pass
    try:
        os.close(master)
    except Exception:
        pass

    # Strip ANSI
    text = re.sub(
        r'\x1B\[[0-9;?]*[A-Za-z]|\x1B\][^\x07]*\x07|\x1B[^\[\]]',
        "", output.decode("utf-8", errors="ignore")
    )
    text = re.sub(r'[\x00-\x08\x0b-\x1f]', ' ', text)

    # Write debug
    with open(DEBUG_FILE, "w") as f:
        f.write(f"bytes={len(output)}\n")
        f.write(text[:1000])

    pcts = re.findall(r'(\d+)%\s*used', text)

    # Extract reset time from "Current session" line only (before "Extra usage")
    session_block = text.split("Extra")[0] if "Extra" in text else text
    reset_t = "--"
    for pattern in [
        r'Rese[ts]+\s*([\d:]+(?:am|pm))',   # "Resets 5:59pm" or garbled "Reses5:59pm"
        r'Rese[ts]+\s*(\d+h\s*\d+m)',        # "Resets 1h 30m"
        r'Rese[ts]+\s*(\d+m)',               # "Resets 1m"
        r'([\d:]+(?:am|pm))',                # fallback: bare time
    ]:
        m = re.search(pattern, session_block, re.IGNORECASE)
        if m:
            reset_t = m.group(1).strip()
            break

    session = int(pcts[0]) if len(pcts) > 0 else 0
    extra   = int(pcts[1]) if len(pcts) > 1 else 0
    write_result(session, extra, reset_t)


def write_result(session, extra, reset, error=None):
    data = {
        "session": session,
        "extra": extra,
        "reset": reset,
        "timestamp": time.time(),
    }
    if error:
        data["error"] = error
    with open(OUTPUT_FILE, "w") as f:
        json.dump(data, f)
    print(json.dumps(data))


if __name__ == "__main__":
    get_usage()
