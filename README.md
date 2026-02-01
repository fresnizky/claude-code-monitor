# Claude Code Dashboard

A macOS menu bar app that monitors multiple Claude Code sessions in real time.

The app reads a shared JSON state file (`~/.claude/dashboard-state.json`) updated by Claude Code hooks, showing session status, token usage, and duration at a glance.

## Features

- Menu bar icon changes shape based on session status (idle, working, waiting for input, error)
- Badge count for sessions needing attention
- Session list with project name, status detail, token count, and duration
- Hide/unhide sessions
- Automatic cleanup of stale sessions (>24h)

## Prerequisites

- macOS 14.0+
- Xcode Command Line Tools (`xcode-select --install`)

## Install

```bash
git clone <repo-url>
cd claude-code-monitor
./install.sh
```

The installer will:
1. Build the app with `swift build`
2. Copy `Claude Code Dashboard.app` to `/Applications`
3. Install the hook script to `~/.claude/hooks/`
4. Ask to add hooks to `~/.claude/settings.json` (with backup)

## Build Only

```bash
make build    # Build .app bundle in build/
make run      # Build and open
make clean    # Remove build artifacts
```

## Manual Hook Configuration

If you skip automatic hook configuration during install, add the following to `~/.claude/settings.json`:

```json
{
  "hooks.PreToolUse": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/dashboard-update.sh",
          "timeout": 10,
          "async": true
        }
      ]
    }
  ],
  "hooks.PostToolUse": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/dashboard-update.sh",
          "timeout": 10,
          "async": true
        }
      ]
    }
  ],
  "hooks.Notification": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/dashboard-update.sh",
          "timeout": 10,
          "async": true
        }
      ]
    }
  ],
  "hooks.Stop": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/dashboard-update.sh",
          "timeout": 10,
          "async": true
        }
      ]
    }
  ]
}
```

## How It Works

1. Claude Code hooks fire on tool use, notifications, and session stop events
2. The hook script (`dashboard-update.sh`) updates `~/.claude/dashboard-state.json` with session status
3. The menu bar app polls the state file every 3 seconds (only reads if the file has changed)
4. Session states are displayed in a popover with status icons, token counts, and durations

### Menu Bar Icons

| Icon | Meaning |
|------|---------|
| `○` (circle) | No active sessions or all idle |
| `●` (filled circle) | At least one session is working |
| `⚠` (exclamation circle) | Session waiting for input (with count badge) |
| `✕` (x circle) | Session has an error |

## Troubleshooting

**App doesn't appear in menu bar**
- Check that `LSUIElement` is `true` in Info.plist (it's a menu-bar-only app, no dock icon)
- Try `open '/Applications/Claude Code Dashboard.app'`

**Sessions not updating**
- Verify hooks are in `~/.claude/settings.json`
- Test the hook manually:
  ```bash
  echo '{"session_id":"test","cwd":"/tmp","hook_event_name":"PreToolUse","tool_name":"Bash"}' | ~/.claude/hooks/dashboard-update.sh
  cat ~/.claude/dashboard-state.json
  ```

**Build fails**
- Ensure Xcode CLT is installed: `xcode-select --install`
- Requires macOS 14.0+ and Swift 5.9+
