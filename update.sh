#!/bin/bash

set -e

REPO_RAW="https://raw.githubusercontent.com/traedamatic/init/main"

if [ ! -f code_guidelines.md ]; then
  echo "Error: code_guidelines.md not found in $(pwd)."
  echo "Run this from the root of a project initialized with init.sh."
  exit 1
fi

echo "Updating code_guidelines.md..."
curl -fsSL -o code_guidelines.md "$REPO_RAW/code_guidelines.md"
echo "  - Updated code_guidelines.md"

CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS_DIR"

echo "Updating Claude Code commands..."
for cmd in el-create-ticket el-dev-loop; do
  curl -fsSL -o "$CLAUDE_COMMANDS_DIR/$cmd.md" "$REPO_RAW/commands/$cmd.md"
  echo "  - Updated /$cmd"
done

echo ""
echo "Update complete."
echo "  - code_guidelines.md refreshed in $(pwd)"
echo "  - el-create-ticket, el-dev-loop refreshed in $CLAUDE_COMMANDS_DIR"
echo ""
echo "Run 'git diff code_guidelines.md' to review changes before committing."
