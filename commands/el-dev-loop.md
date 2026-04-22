---
description: Automated development loop — picks up unassigned Todo tickets from the project board and implements them one by one
argument-hint: [number-of-tickets]
allowed-tools: Bash(gh *), Bash(git *), Bash(bun *), Bash(npm *), Read, Write, Edit, Grep, Glob, Bash(ls *)
---

# Engineer Loop — Dev Loop

Automated development loop that picks up unassigned Todo tickets from the GitHub Project board and implements them sequentially: branch, code, test, commit, comment, and mark done.

## Instructions

### 1. Parse Arguments

- `$ARGUMENTS` optionally contains the maximum number of tickets to process
- If empty or not a number: process ALL unassigned Todo tickets
- Store as `MAX_TICKETS`

### 2. Read Project Configuration

Read `CLAUDE.md` at the project root and extract the `## GitHub Project` section:
- **Owner**
- **Repository**
- **Project Number**
- **Project ID**
- **Status Field ID**
- **Status Option IDs**: Todo, In Progress, Done

If the `## GitHub Project` section is missing, stop and report:
"CLAUDE.md is missing the `## GitHub Project` section. Add it to use this command."

Also read:
- Full `CLAUDE.md` — architecture, conventions, development commands (especially the test command)
- `code_guidelines.md` if it exists — coding standards to follow during implementation

### 3. Check Prerequisites

**GitHub CLI:**
```bash
gh auth status
```
If not authenticated, stop: "Please authenticate with: `gh auth login`"

**Clean working tree:**
```bash
git status --porcelain
```
If dirty, stop: "Working tree has uncommitted changes. Please commit or stash before running /el-dev-loop."

**On main branch and up to date:**
```bash
git checkout main
git pull origin main
```

### 4. Fetch Todo Tickets

```bash
gh project item-list <PROJECT_NUMBER> --owner <OWNER> --format json --limit 100
```

Filter the JSON result for items where:
- `status` equals `"Todo"`
- `assignees` is empty (no one assigned)
- `content.type` equals `"Issue"`

Sort by issue number **ascending** (oldest first).

If no qualifying tickets exist:
"No unassigned Todo tickets found in the project. Nothing to do." → stop.

Display:
```
## Dev Loop: Found N unassigned Todo ticket(s)

1. #<NUM> — <TITLE>
2. #<NUM> — <TITLE>
...

Processing: <MIN(N, MAX_TICKETS)> ticket(s)
Starting...
```

### 5. Process Each Ticket

Initialize counters: `PROCESSED = 0`, `FAILED = 0`

For each ticket (up to `MAX_TICKETS`):

---

#### 5a. Assign and Move to In Progress

Assign the issue:
```bash
gh issue edit <ISSUE_NUMBER> --repo <OWNER>/<REPO> --add-assignee @me
```

Move to "In Progress":
```bash
gh project item-edit \
  --id <ITEM_ID> \
  --project-id <PROJECT_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <IN_PROGRESS_OPTION_ID>
```

---

#### 5b. Fetch Full Issue Details

```bash
gh issue view <ISSUE_NUMBER> --repo <OWNER>/<REPO> --json number,title,body,labels
```

Parse the issue body to understand:
- What needs to be built (scope, acceptance criteria)
- Technical notes and implementation hints
- Referenced file paths
- Definition of done

---

#### 5c. Analyze the Codebase

Based on the issue content:
- Use **Grep** and **Glob** to find files mentioned in the ticket
- Use **Read** to examine relevant source files
- Identify:
  - Files to create or modify
  - Existing patterns to follow
  - Database schema changes needed
  - Component structure to extend
  - Test files to add or update

---

#### 5d. Create Feature Branch

Determine branch prefix:
- If labels contain `bug` or body describes a fix: `fix`
- Otherwise: `feature`

Generate branch name:
1. Take issue title
2. Lowercase, replace spaces with hyphens, remove special chars (keep a-z, 0-9, hyphens)
3. Truncate slug to 40 characters
4. Format: `<prefix>/<ISSUE_NUMBER>-<slug>`

Example: `feature/4-user-can-see-a-dashboard`

```bash
git checkout main
git pull origin main
git checkout -b <BRANCH_NAME>
```

If branch already exists, append `-v2` (then `-v3`, etc.).

---

#### 5e. Implement the Changes

Follow ALL conventions from CLAUDE.md and code_guidelines.md. Key reminders:
- TypeScript strict mode — no `any`, use `unknown`
- `const` over `let`, never `var`
- `async/await` over raw promise chains
- Named exports (except Svelte components which use default exports)
- Early returns to reduce nesting
- DRY, single responsibility, composition over inheritance
- Use Bun APIs over Node.js equivalents where the project uses Bun
- Small, focused changes

Implementation approach:
1. Start with data model / schema changes if needed
2. Implement backend logic
3. Add RPC handlers if frontend-backend communication is needed
4. Implement frontend components
5. Add tests alongside implementation

Use existing patterns found in the codebase — do not invent new patterns when established ones exist.

---

#### 5f. Run Tests

Detect the test command from CLAUDE.md's Development section (e.g., `bun test`, `npm test`).

```bash
bun test
```

- If tests pass: proceed to commit
- If tests fail:
  - Read the output carefully
  - Fix failing tests (both new and existing)
  - Re-run tests
  - If still failing after **3 attempts**:
    - Record this ticket as **FAILED**
    - Add a comment to the issue explaining what was attempted and what failed
    - Clean up: `git checkout main`, delete the branch
    - Move the issue back to Todo and unassign
    - Continue to the next ticket

---

#### 5g. Commit Changes

Stage changed files individually — do NOT use `git add .` or `git add -A`:
```bash
git add <file1> <file2> ...
```

Create commit(s) with conventional commit messages:
```bash
git commit -m "<type>: <description>

<body explaining what was done and why>

Refs #<ISSUE_NUMBER>"
```

Commit types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

If the implementation touches multiple concerns, create **multiple commits** — one per logical change. Keep commits small and focused.

---

#### 5h. Comment on the Issue

```bash
gh issue comment <ISSUE_NUMBER> --repo <OWNER>/<REPO> --body "<comment>"
```

Comment format:
```
## Implementation Summary

**Branch:** `<BRANCH_NAME>`

### Changes Made
- `<file1>`: <what was changed and why>
- `<file2>`: <what was changed and why>

### Acceptance Criteria Status
- [x] <criterion met>
- [x] <criterion met>
- [ ] <criterion not met — explanation>

### Tests
- Test command: `<test command>` — passing
- <summary of test coverage added>

### Notes
<any caveats, follow-up work, or decisions made during implementation>
```

---

#### 5i. Move to Done

```bash
gh project item-edit \
  --id <ITEM_ID> \
  --project-id <PROJECT_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <DONE_OPTION_ID>
```

Increment `PROCESSED`.

---

#### 5j. Return to Main

```bash
git checkout main
```

Print progress:
```
Completed #<NUM> — <TITLE> (PROCESSED/TOTAL). Moving to next...
```

---

### 6. Final Summary

After all tickets are processed (or limit reached):

```
## Dev Loop Complete

**Processed:** <PROCESSED> ticket(s)
**Failed:** <FAILED> ticket(s)

| # | Title | Branch | Status |
|---|-------|--------|--------|
| <NUM> | <TITLE> | `<BRANCH>` | Done |
| <NUM> | <TITLE> | — | Failed: <reason> |

### Branches Created
- `feature/4-user-can-see-a-dashboard`
- `feature/5-recurring-transaction-detection`

### Next Steps
- Review each branch locally and open PRs when ready
- Use `git log <branch>` to review commits
- Use `git diff main..<branch>` to review full diff
```

## Error Handling and Resilience

The loop MUST be resilient. A single ticket failure does NOT stop the loop.

**For each failure type:**
- **Assign fails**: Skip ticket, log warning, continue
- **Branch creation fails**: Try with `-v2` suffix, or skip
- **Implementation fails** (can't figure out what to do): Comment on issue, move back to Todo, unassign, continue
- **Tests fail after 3 attempts**: Comment with failure details, revert, move back to Todo, unassign, continue
- **Commit fails**: Show error, attempt recovery, skip if unrecoverable
- **`gh project item-edit` fails**: Log warning but don't block — the code was committed successfully

**After any failure, always ensure:**
1. Working tree is clean (checkout main, clean up branch if needed)
2. Issue is moved back to Todo and unassigned (not stuck in limbo)
3. A comment is left on the issue explaining what happened

## Important Rules

- Do NOT push branches to remote — the user reviews locally first
- Do NOT create pull requests — local development only
- Each ticket is a full cycle: branch → code → test → commit → comment → done
- Follow ALL conventions from CLAUDE.md and code_guidelines.md
- Read the full issue body carefully — tickets may be detailed with ACs, technical notes, and scope
- The authenticated GitHub user is the one running the loop — `@me` resolves to them
