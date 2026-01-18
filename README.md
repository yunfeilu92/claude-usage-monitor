# Claude Usage Monitor

Real-time Claude Code usage monitoring tool for iTerm2 Status Bar on macOS.

![Claude Usage in Status Bar](docs/screenshot.png)

## Features

- Display Claude Code session and weekly usage limits in iTerm2 Status Bar
- Automatic usage fetching every minute via launchd
- Shows session usage percentage and reset time
- Shows weekly usage percentage and reset date
- Manual fallback option for setting usage info

## Requirements

- macOS
- iTerm2
- zsh (with Oh My Zsh recommended)
- tmux (`brew install tmux`)
- Claude Code CLI

## Installation

### 1. Install Scripts

```bash
# Clone the repository
git clone https://github.com/YunfeiLu/claude-usage-monitor.git
cd claude-usage-monitor

# Copy scripts to ~/.local/bin
mkdir -p ~/.local/bin
cp scripts/* ~/.local/bin/
chmod +x ~/.local/bin/claude-*
```

### 2. Configure Shell

Add to your `~/.zshrc`:

```bash
# Claude Code Usage Monitor
export PATH="$HOME/.local/bin:$PATH"

# iTerm2 user variable for status bar
iterm2_set_user_var() {
    printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(echo -n "$2" | base64)
}

_update_claude_usage() {
    local usage=""
    if [[ -x "$HOME/.local/bin/claude-usage-iterm" ]]; then
        usage=$("$HOME/.local/bin/claude-usage-iterm" 2>/dev/null)
    fi
    iterm2_set_user_var claudeUsage "${usage:-Claude: --}"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_claude_usage
```

Reload your shell:
```bash
source ~/.zshrc
```

### 3. Configure iTerm2 Status Bar

1. Open iTerm2 Preferences (`Cmd + ,`)
2. Go to **Profiles** → Select your profile → **Session** tab
3. Enable **Status bar enabled**
4. Click **Configure Status Bar**
5. Drag **Interpolated String** to the status bar
6. Click the component to configure it
7. Set the string value to: `\(user.claudeUsage)`

### 4. Install LaunchAgent (Auto-update)

```bash
# Create usage directory
mkdir -p ~/.claude

# Copy and customize the plist file
cp launchagent/com.claude.usage-fetch.plist ~/Library/LaunchAgents/

# Edit the plist to update the home directory path
sed -i '' "s|__HOME__|$HOME|g" ~/Library/LaunchAgents/com.claude.usage-fetch.plist

# Load the agent
launchctl load ~/Library/LaunchAgents/com.claude.usage-fetch.plist
```

## Scripts

| Script | Description |
|--------|-------------|
| `claude-usage` | Full-featured CLI tool with multiple display modes |
| `claude-usage-iterm` | Simplified output for iTerm2 Status Bar |
| `claude-fetch-usage` | Automated /usage fetcher using tmux |
| `claude-usage-set` | Manual usage info setter (backup method) |

## Usage

### Automatic Mode

Once installed, the launchd agent will automatically fetch usage info every minute. The Status Bar will display something like:

```
Claude: Session: 44% used (Resets 1:59am) | Week: 16% used (Resets Jan 24)
```

### Manual Mode

If automation fails, you can manually set usage info:

```bash
# Run /usage in Claude Code, then copy the info
claude-usage-set "Session: 50% | Week: 20%"
```

### CLI Tool

```bash
# Show summary
claude-usage

# Show daily stats
claude-usage -d

# Show weekly stats
claude-usage -w

# Show JSON output
claude-usage -j
```

## Troubleshooting

### Status Bar shows "Claude: --"

1. Check if usage file exists:
   ```bash
   cat ~/.claude/usage-limit.txt
   ```

2. Manually run the fetch script:
   ```bash
   claude-fetch-usage
   ```

3. Check the debug log:
   ```bash
   cat /tmp/claude_usage_debug.txt
   ```

### LaunchAgent not running

```bash
# Check status
launchctl list | grep claude

# View logs
cat /tmp/claude-usage-fetch.log

# Reload agent
launchctl unload ~/Library/LaunchAgents/com.claude.usage-fetch.plist
launchctl load ~/Library/LaunchAgents/com.claude.usage-fetch.plist
```

### tmux session stuck

```bash
# Kill stuck session
tmux kill-session -t claude_usage_fetch

# Remove lock file
rm /tmp/claude-fetch-usage.lock
```

## How It Works

1. **LaunchAgent** triggers `claude-fetch-usage` every minute
2. **claude-fetch-usage** creates a tmux session, runs Claude CLI, executes `/usage`, and parses the output
3. Usage info is saved to `~/.claude/usage-limit.txt`
4. **zsh precmd hook** reads the file via `claude-usage-iterm` and sets iTerm2 user variable
5. **iTerm2 Status Bar** displays the interpolated user variable

## License

MIT

## Author

Yunfei Lu
