# ClaudeBar

A macOS menu bar app that shows your Claude token usage at a glance.

```
Token  36% · resets 5:59pm
```

## Requirements

- macOS 14.0+
- [Claude Code CLI](https://claude.ai/code) installed (`/opt/homebrew/bin/claude`)
- Claude Pro account

## Install

1. Download `ClaudeBar.app` from [Releases](../../releases)
2. Run the install script:

```bash
bash install.sh
```

3. Open `ClaudeBar.app`

## How it works

A LaunchAgent runs `claude /usage` every 60 seconds and writes the result to `/tmp/claudebar-usage.json`. The menu bar app reads this file every 30 seconds and displays session usage %.

Click the menu bar icon to see session %, extra %, reset time, and last updated time.

## Build from source

```bash
xcodebuild -scheme ClaudeBar -configuration Release -derivedDataPath build
open build/Build/Products/Release/ClaudeBar.app
```

## License

MIT
