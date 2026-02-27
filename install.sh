#!/bin/bash
# ClaudeBar install script
set -e

HOME_DIR="$HOME"
PLIST_SRC="$(dirname "$0")/com.claudebar.plist"
SCRIPT_SRC="$(dirname "$0")/claudebar_fetch.py"
PLIST_DST="$HOME_DIR/Library/LaunchAgents/com.claudebar.plist"
SCRIPT_DST="$HOME_DIR/.claude/claudebar_fetch.py"

echo "Installing ClaudeBar..."

# Copy fetch script
mkdir -p "$HOME_DIR/.claude"
cp "$SCRIPT_SRC" "$SCRIPT_DST"
echo "  ✓ Installed fetch script to $SCRIPT_DST"

# Install LaunchAgent with correct home path
sed "s|HOME_PLACEHOLDER|$HOME_DIR|g" "$PLIST_SRC" > "$PLIST_DST"
echo "  ✓ Installed LaunchAgent to $PLIST_DST"

# Load LaunchAgent
launchctl unload "$PLIST_DST" 2>/dev/null || true
launchctl load "$PLIST_DST"
echo "  ✓ LaunchAgent loaded"

echo ""
echo "Done! Open ClaudeBar.app to get started."
