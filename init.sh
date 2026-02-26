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

# Create .gitignore for Node.js, Bun, TypeScript
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp/
.pnp.js

# Build outputs
dist/
build/
out/
.next/
.nuxt/
.output/

# TypeScript
*.tsbuildinfo
tsconfig.tsbuildinfo

# Bun
bun.lockb
.bun/

# Environment files
.env
.env.local
.env.*.local
.env.development
.env.production

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# OS files
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Test coverage
coverage/
.nyc_output/

# Cache
.cache/
.eslintcache
.prettiercache
*.cache

# Temporary files
tmp/
temp/
EOF

# Create empty pre-commit hook as template
cat > git_hooks/pre-commit << 'EOF'
#!/bin/sh

# Add your pre-commit checks here
# Example: npm run lint && npm run test

exit 0
EOF

chmod +x git_hooks/pre-commit

echo ""
echo "Repository initialized successfully!"
echo "  - Git initialized with 'main' branch"
echo "  - git_hooks/ directory created"
echo "  - core.hooksPath set to git_hooks/"
echo "  - .gitignore created for Node.js/Bun/TypeScript"
echo ""
echo "Edit git_hooks/pre-commit to add your hooks."
EOF
