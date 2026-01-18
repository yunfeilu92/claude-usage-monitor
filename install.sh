#!/bin/bash
# Claude Usage Monitor - Installation Script

set -e

echo "Installing Claude Usage Monitor..."

# Create directories
mkdir -p ~/.local/bin
mkdir -p ~/.claude

# Copy scripts
cp scripts/* ~/.local/bin/
chmod +x ~/.local/bin/claude-usage
chmod +x ~/.local/bin/claude-usage-iterm
chmod +x ~/.local/bin/claude-fetch-usage
chmod +x ~/.local/bin/claude-usage-set

echo "✓ Scripts installed to ~/.local/bin/"

# Install LaunchAgent
PLIST_FILE=~/Library/LaunchAgents/com.claude.usage-fetch.plist
cp launchagent/com.claude.usage-fetch.plist "$PLIST_FILE"
sed -i '' "s/yunfeilu/$USER/g" "$PLIST_FILE"

# Load LaunchAgent
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo "✓ LaunchAgent installed and loaded"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Add the following to your ~/.zshrc:"
echo ""
cat << 'EOF'
# Claude Code Usage Monitor
export PATH="$HOME/.local/bin:$PATH"

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
EOF
echo ""
echo "2. Configure iTerm2 Status Bar with Interpolated String: \\(user.claudeUsage)"
echo ""
