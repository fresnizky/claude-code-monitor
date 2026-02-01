#!/bin/bash
# Claude Code Dashboard - Installer
# Builds the app, installs it, and configures Claude Code hooks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Claude Code Dashboard.app"
INSTALL_DIR="/Applications"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_SCRIPT="$HOOKS_DIR/dashboard-update.sh"

echo "=== Claude Code Dashboard Installer ==="
echo ""

# Check dependencies
echo "Checking dependencies..."
if ! command -v swift &>/dev/null; then
    echo "Error: Swift compiler not found. Install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

if ! command -v lockf &>/dev/null; then
    echo "Error: lockf not found (should be available on macOS by default)."
    exit 1
fi

if ! /usr/bin/python3 --version &>/dev/null; then
    echo "Error: /usr/bin/python3 not found. Install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

echo "  swift: $(swift --version 2>&1 | head -1)"
echo "  python3: $(/usr/bin/python3 --version)"
echo "  lockf: available"
echo ""

# Build the app
echo "Building the app..."
make -C "$SCRIPT_DIR" build
echo ""

# Install the app
echo "Installing to $INSTALL_DIR..."
if [ -d "$INSTALL_DIR/$APP_NAME" ]; then
    echo "  Removing existing installation..."
    rm -rf "$INSTALL_DIR/$APP_NAME"
fi
cp -R "$SCRIPT_DIR/build/$APP_NAME" "$INSTALL_DIR/"
echo "  Installed to $INSTALL_DIR/$APP_NAME"
echo ""

# Install hook script
echo "Installing hook script..."
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR/hooks/dashboard-update.sh" "$HOOK_SCRIPT"
chmod +x "$HOOK_SCRIPT"
echo "  Installed to $HOOK_SCRIPT"
echo ""

# Configure Claude Code hooks
echo "Configuring Claude Code hooks..."

# Check if hooks are already installed
ALREADY_INSTALLED=false
if [ -f "$SETTINGS_FILE" ]; then
    if /usr/bin/python3 -c "
import json, sys
with open('$SETTINGS_FILE', 'r') as f:
    settings = json.load(f)
for key in ['hooks.PreToolUse', 'hooks.PostToolUse', 'hooks.Notification', 'hooks.Stop']:
    items = settings.get(key, [])
    for item in items:
        for hook in item.get('hooks', []):
            if 'dashboard-update.sh' in hook.get('command', ''):
                sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
        ALREADY_INSTALLED=true
    fi
fi

if [ "$ALREADY_INSTALLED" = true ]; then
    echo "  Dashboard hooks already configured in settings.json"
else
    echo ""
    echo "  The installer needs to add hooks to: $SETTINGS_FILE"
    echo "  This will add async hooks for: PreToolUse, PostToolUse, Notification, Stop"
    echo "  Existing hooks will be preserved."
    echo ""
    read -rp "  Add dashboard hooks to Claude Code settings? [Y/n] " response
    response="${response:-Y}"

    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Create backup
        if [ -f "$SETTINGS_FILE" ]; then
            BACKUP="$SETTINGS_FILE.backup.$(date +%Y%m%d%H%M%S)"
            cp "$SETTINGS_FILE" "$BACKUP"
            echo "  Backup saved to $BACKUP"
        fi

        # Merge hooks using python3
        /usr/bin/python3 -c "
import json, os

settings_file = '$SETTINGS_FILE'
hook_command = os.path.expanduser('$HOOK_SCRIPT')

# Read existing settings
settings = {}
if os.path.exists(settings_file):
    try:
        with open(settings_file, 'r') as f:
            settings = json.load(f)
    except (json.JSONDecodeError, IOError):
        pass

dashboard_hook = {
    'type': 'command',
    'command': hook_command,
    'timeout': 10,
    'async': True
}

# Hook configurations to add
hook_configs = {
    'hooks.PreToolUse': {'matcher': '', 'hooks': [dashboard_hook]},
    'hooks.PostToolUse': {'matcher': '', 'hooks': [dashboard_hook]},
    'hooks.Notification': {'matcher': '', 'hooks': [dashboard_hook]},
    'hooks.Stop': {'matcher': '', 'hooks': [dashboard_hook]},
}

for key, new_entry in hook_configs.items():
    existing = settings.get(key, [])
    if not isinstance(existing, list):
        existing = []
    # Check if dashboard hook already exists
    found = False
    for entry in existing:
        for hook in entry.get('hooks', []):
            if 'dashboard-update.sh' in hook.get('command', ''):
                found = True
                break
        if found:
            break
    if not found:
        existing.append(new_entry)
    settings[key] = existing

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)
"
        echo "  Hooks added to settings.json"
    else
        echo "  Skipped. You can manually configure hooks later."
        echo "  See README.md for manual hook configuration."
    fi
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "To start the dashboard:"
echo "  open '/Applications/$APP_NAME'"
echo ""
echo "The app will appear in your menu bar."
