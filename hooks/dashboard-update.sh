#!/bin/bash
# Claude Code Dashboard - Hook Script
# Updates ~/.claude/dashboard-state.json when Claude Code events fire.
# Uses /usr/bin/python3 for JSON manipulation (no jq dependency).
# Uses lockf for file locking (macOS native).

set -euo pipefail

STATE_DIR="$HOME/.claude"
STATE_FILE="$STATE_DIR/dashboard-state.json"
LOCK_FILE="$STATE_DIR/dashboard-state.lock"
MAX_SESSIONS=50

# Read hook event from stdin
INPUT="$(cat)"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Pass input via environment variable to avoid shell escaping issues
export DASHBOARD_HOOK_INPUT="$INPUT"
export DASHBOARD_STATE_FILE="$STATE_FILE"
export DASHBOARD_MAX_SESSIONS="$MAX_SESSIONS"

# Run the update inside a lock
lockf -k -t 5 "$LOCK_FILE" /usr/bin/python3 -c '
import json, sys, os, tempfile
from datetime import datetime, timezone

raw_input = os.environ.get("DASHBOARD_HOOK_INPUT", "")
state_file = os.environ["DASHBOARD_STATE_FILE"]
max_sessions = int(os.environ["DASHBOARD_MAX_SESSIONS"])

try:
    input_data = json.loads(raw_input)
except json.JSONDecodeError:
    sys.exit(0)

session_id = input_data.get("session_id", "")
cwd = input_data.get("cwd", "")
hook_event = input_data.get("hook_event_name", "")
tool_name = input_data.get("tool_name", "")

if not session_id:
    sys.exit(0)

# Determine status from hook event
if hook_event == "PreToolUse":
    status = "working"
    status_detail = ("Running " + tool_name) if tool_name else "Working..."
elif hook_event == "PostToolUse":
    status = "working"
    status_detail = ("Completed " + tool_name) if tool_name else "Working..."
elif hook_event == "Notification":
    status = "waiting_input"
    status_detail = "Waiting for input"
elif hook_event == "Stop":
    status = "idle"
    status_detail = "Session ended"
else:
    status = "working"
    status_detail = hook_event

now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

# Read existing state
state = {"version": 1, "sessions": [], "hidden_sessions": []}
if os.path.exists(state_file):
    try:
        with open(state_file, "r") as f:
            state = json.load(f)
    except (json.JSONDecodeError, IOError):
        pass

# Find or create session
sessions = state.get("sessions", [])
existing = None
for s in sessions:
    if s.get("session_id") == session_id:
        existing = s
        break

if existing:
    existing["status"] = status
    existing["status_detail"] = status_detail
    existing["updated_at"] = now
    if cwd:
        existing["cwd"] = cwd
else:
    new_session = {
        "session_id": session_id,
        "cwd": cwd,
        "status": status,
        "status_detail": status_detail,
        "updated_at": now,
        "started_at": now,
        "token_usage": None,
    }
    sessions.append(new_session)

# Prune oldest sessions if over limit
if len(sessions) > max_sessions:
    sessions.sort(key=lambda s: s.get("updated_at", ""))
    sessions = sessions[-max_sessions:]

state["sessions"] = sessions

# Atomic write via temp file + rename
fd, tmp_path = tempfile.mkstemp(dir=os.path.dirname(state_file))
try:
    with os.fdopen(fd, "w") as f:
        json.dump(state, f, indent=2)
    os.rename(tmp_path, state_file)
except:
    os.unlink(tmp_path)
    raise
'
