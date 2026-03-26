#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing claude-settings from $REPO_DIR"

# --- ~/.claude/statusline.py ---
mkdir -p "$HOME/.claude"
cp "$REPO_DIR/statusline.py" "$HOME/.claude/statusline.py"
chmod +x "$HOME/.claude/statusline.py"
echo "  Copied statusline.py"

# --- ~/.claude/CLAUDE.md ---
cp "$REPO_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
echo "  Copied CLAUDE.md"

# --- ~/.claude/settings.json: statusLine の追加 ---
SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# すでに設定済みかチェック
if grep -q '"statusLine"' "$SETTINGS"; then
  echo "  settings.json: statusLine already configured, skipping"
else
  # python3 で JSON をマージ
  python3 - "$SETTINGS" <<'PYEOF'
import json, sys

path = sys.argv[1]
with open(path) as f:
    data = json.load(f)

data["statusLine"] = {
    "type": "command",
    "command": "~/.claude/statusline.py"
}

with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')

print("  settings.json: statusLine added")
PYEOF
fi

echo "Done."
