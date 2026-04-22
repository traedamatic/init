#!/bin/bash

set -e

# Get project path from argument or use current directory
PROJECT_PATH="${1:-.}"

# Create directory if it doesn't exist
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH"

echo "Initializing repository in $(pwd)..."

# Initialize git repo with main as default branch
git init -b main

# Create git_hooks directory
mkdir -p git_hooks

# Set git to use custom hooks path
git config core.hooksPath git_hooks

# Download .gitignore for Node.js, Bun, TypeScript
echo "Downloading .gitignore..."
curl -fsSL -o .gitignore "https://raw.githubusercontent.com/traedamatic/init/main/.gitignore_template"

# Create empty pre-commit hook as template
cat > git_hooks/pre-commit << 'EOF'
#!/bin/sh

# Add your pre-commit checks here
# Example: npm run lint && npm run test

exit 0
EOF

chmod +x git_hooks/pre-commit

# Download code guidelines
echo "Downloading code guidelines..."
curl -fsSL -o code_guidelines.md "https://raw.githubusercontent.com/traedamatic/init/main/code_guidelines.md"

# Download CLAUDE.md
echo "Downloading CLAUDE.md..."
curl -fsSL -o CLAUDE.md "https://raw.githubusercontent.com/traedamatic/init/main/CLAUDE.md"

# Install Claude Code global commands (el- engineer loop)
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS_DIR"

echo "Installing Claude Code commands..."
for cmd in el-create-ticket el-dev-loop; do
  if [ ! -f "$CLAUDE_COMMANDS_DIR/$cmd.md" ]; then
    curl -fsSL -o "$CLAUDE_COMMANDS_DIR/$cmd.md" "https://raw.githubusercontent.com/traedamatic/init/main/commands/$cmd.md"
    echo "  - Installed /el-$cmd → $CLAUDE_COMMANDS_DIR/$cmd.md"
  else
    echo "  - Skipped /$cmd (already exists)"
  fi
done

echo ""
echo "Repository initialized successfully!"
echo "  - Git initialized with 'main' branch"
echo "  - git_hooks/ directory created"
echo "  - core.hooksPath set to git_hooks/"
echo "  - .gitignore downloaded"
echo "  - code_guidelines.md downloaded"
echo "  - CLAUDE.md downloaded"
echo "  - Claude Code commands installed (el-create-ticket, el-dev-loop)"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md — fill in the GitHub Project section with your project IDs"
echo "  2. Edit git_hooks/pre-commit to add your hooks"
echo "  3. Use /el-create-ticket to create tickets and /el-dev-loop to develop them"
