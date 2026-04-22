# init

Bootstrap script for new Node.js/Bun/TypeScript repositories with Claude Code workflow support.

## What it does

- Initializes git with `main` branch
- Sets up `git_hooks/` directory with custom hooks path
- Downloads `.gitignore`, `code_guidelines.md`, and `CLAUDE.md`
- Installs global Claude Code commands for the engineer loop workflow

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/traedamatic/init/main/init.sh | bash -s /path/to/project
```

## Engineer Loop Workflow

Two Claude Code slash commands that create a ticket-driven development loop for any project.

### Prerequisites

1. [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth login`)
2. A [GitHub Project (v2)](https://docs.github.com/en/issues/planning-and-tracking-with-projects) with a Status field (Todo / In Progress / Done)
3. The `## GitHub Project` section in your project's `CLAUDE.md` filled in with your project IDs

### Setup

After running `init.sh`, edit your project's `CLAUDE.md` and fill in the `## GitHub Project` section:

```markdown
## GitHub Project

- **Owner**: your-username
- **Repository**: your-repo
- **Project Number**: 3
- **Project URL**: https://github.com/users/your-username/projects/3
- **Project ID**: PVT_...
- **Status Field ID**: PVTSSF_...
- **Status Options**:
  - Todo: `<option-id>`
  - In Progress: `<option-id>`
  - Done: `<option-id>`
```

To find your project IDs:

```bash
gh project list --owner <OWNER>
gh project field-list <PROJECT_NUMBER> --owner <OWNER>
```

### Commands

#### `/el-create-ticket <description>`

Creates a GitHub issue from a rough description and adds it to the project board.

1. Reads project config from `CLAUDE.md`
2. Explores the codebase for technical context
3. Writes a detailed, implementation-ready ticket (acceptance criteria, technical notes with real file paths, scope boundaries)
4. Previews the ticket for confirmation
5. Creates the GitHub issue and adds it to the project board (Todo column)

#### `/el-dev-loop [number-of-tickets]`

Automated development loop that picks up unassigned Todo tickets and implements them.

1. Fetches all unassigned Todo tickets from the project board
2. For each ticket: assigns it, moves to In Progress, creates a feature branch, implements the changes, runs tests, commits, comments on the issue, and moves to Done
3. Resilient — if a ticket fails, it goes back to Todo and the loop continues
4. Does not push or create PRs — you review locally first

```bash
# Process all unassigned Todo tickets
/el-dev-loop

# Process up to 3 tickets
/el-dev-loop 3
```

### Typical Workflow

```
Phase 1: Create tickets
  /el-create-ticket Users can filter transactions by date range
  /el-create-ticket Add export to CSV from the transaction table
  /el-create-ticket Fix pagination resetting when filters change

Phase 2: Develop
  /el-dev-loop
```

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Template for project-level Claude Code instructions + GitHub Project config |
| `code_guidelines.md` | Coding standards for TypeScript/Bun projects |
| `.gitignore_template` | Standard .gitignore for Node.js/Bun/TypeScript |
| `init.sh` | Bootstrap script |
| `commands/el-create-ticket.md` | Claude Code command: create tickets |
| `commands/el-dev-loop.md` | Claude Code command: development loop |

## License

MIT
