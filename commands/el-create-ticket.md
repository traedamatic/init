---
description: Create a GitHub issue from a rough description, explore codebase for context, and add to project board (Todo)
argument-hint: <description of the feature, bug, or task>
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob
---

# Engineer Loop — Create Ticket

Take a rough requirement description, explore the codebase for technical context, produce a high-quality implementation-ready GitHub issue, and add it to the project board in the Todo column.

## Instructions

### 1. Validate Input

- The user's requirement description is in `$ARGUMENTS`
- If `$ARGUMENTS` is empty, respond: "Usage: /el-create-ticket <description of the feature, bug, or task>"

### 2. Read Project Configuration

Read `CLAUDE.md` at the project root and extract the `## GitHub Project` section:
- **Owner** (e.g., `traedamatic`)
- **Repository** (e.g., `financeview`)
- **Project Number** (e.g., `3`)
- **Project ID** (e.g., `PVT_kwHOAAK5Cs4BVCKY`)
- **Status Field ID**
- **Todo Option ID** (from Status Options)

If the `## GitHub Project` section is missing, stop and report:
"CLAUDE.md is missing the `## GitHub Project` section. Add it with Owner, Repository, Project Number, Project ID, Status Field ID, and Status Options to use this command."

Also read:
- Architecture and Coding Conventions sections from `CLAUDE.md` for project context
- `code_guidelines.md` if it exists — for coding standards that inform technical notes

### 3. Explore the Codebase

Based on the user's description, search the codebase for relevant context:

- Use **Glob** to find files related to the described feature area
- Use **Grep** to search for related function names, types, patterns, or keywords
- Use **Read** to examine 2–4 of the most relevant files

Take note of:
- Specific file paths relevant to the implementation
- Existing utilities or patterns to reuse (don't duplicate)
- Database tables and schema details if relevant
- Component patterns and naming conventions
- RPC / API patterns if frontend-backend communication is involved

### 4. Determine Ticket Type

Infer the type from the description — don't ask unless genuinely ambiguous:

| Type | When | Framing |
|------|------|---------|
| **Feature** / **User Story** | New user-facing capability | "As a [role], I want [capability], so that [benefit]" |
| **Bug** | Something is broken | "X is broken, should do Y" |
| **Task** | Technical work, not user-facing | "Do X" |
| **Chore** | Maintenance, deps, config | "Upgrade X" / "Configure Y" |
| **Refactor** | Internal change, no behavior change | "Restructure X" |
| **Tech Debt** | Paying back a shortcut | "Replace workaround X" |
| **Spike** | Time-boxed investigation | "Investigate X, recommend Y" |

### 5. Draft the Issue Body

Write the issue body as markdown using this structure. Omit sections that don't apply — don't invent filler:

```
# [<Type>] <Short, specific title — under 80 chars, starts with a verb>

## User story
As a <user>, I want <capability>, so that <benefit>.

## Context
<Why this matters. What exists today, what's missing, user impact.
Reference existing functionality. 2–5 sentences, no fluff.>

## Scope

### In scope
- <Concrete deliverable 1>
- <Concrete deliverable 2>

### Out of scope
- <Explicitly excluded item — prevents implementer over-reach>

## Acceptance criteria
- [ ] <Observable, testable condition 1>
- [ ] <Observable, testable condition 2>
- [ ] <Observable, testable condition 3>

## Technical notes
- <Reference actual file paths from codebase exploration in backticks>
- <Identify existing patterns to follow: "Follow the pattern in `src/...`">
- <Note relevant schema, utilities, RPC handlers to reuse>
- <Suggest approach — as hints, not prescriptions>
- <Use must/should/could to signal requirement strength>

## Definition of done
- [ ] Code merged to main
- [ ] Tests added/updated and passing
- [ ] Manual verification of acceptance criteria

**Priority:** <Critical/High/Medium/Low — justify if non-obvious>
**Labels:** <comma-separated>
**Estimate:** <S/M/L/XL — with brief reasoning>
```

Guidelines:
- Every acceptance criterion must be **observable from outside the code** — if someone without source access can't verify it, it's a technical note, not an AC
- Aim for 3–7 acceptance criteria. More than 7 → consider splitting the ticket
- Technical notes MUST reference actual file paths discovered during exploration
- Put file paths and identifiers in backticks
- Include concrete artifacts (error messages, SQL, sample payloads) in code fences
- The Out of scope section is critical — prevents AI implementers from over-reaching
- Match the user's language (if they wrote in German, write in German)

### 6. Select Labels

Choose labels based on the ticket content. Common labels:
- Type: `bug`, `feature`, `enhancement`, `documentation`, `chore`
- Area: `frontend`, `backend`, `api`, `database`, `transactions`
- Priority: only if the repo uses priority labels

If a needed label doesn't exist, include it anyway — `gh` will handle it.

### 7. Generate Title

- Start with a verb: "Add...", "Fix...", "Migrate...", "Implement..."
- Under 80 characters
- Specific enough to disambiguate in a list view
- Bad: "Fix login" — Good: "Fix login failing with Session Expired after refresh"

### 8. Preview the Ticket

Display the complete ticket to the user:

```
## Preview: New GitHub Issue

**Title:** <title>
**Labels:** <labels>
**Type:** <inferred type>

---

<full issue body>

---
```

Ask: "Does this look good? (yes / edit / cancel)"
- **yes**: Proceed to create
- **edit**: Ask what to change, update, and re-preview
- **cancel**: Abort

### 9. Create the GitHub Issue

```bash
gh issue create \
  --repo <OWNER>/<REPO> \
  --title "<title>" \
  --body "<body>" \
  --label "<label1>,<label2>"
```

Capture the issue URL from the output.

### 10. Add to Project Board

Add the newly created issue to the project:
```bash
gh project item-add <PROJECT_NUMBER> --owner <OWNER> --url <ISSUE_URL>
```

Capture the returned item ID.

### 11. Set Status to Todo

```bash
gh project item-edit \
  --id <ITEM_ID> \
  --project-id <PROJECT_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <TODO_OPTION_ID>
```

### 12. Report Result

```
## Ticket Created

- **Issue:** #<NUMBER> — <TITLE>
- **URL:** <ISSUE_URL>
- **Labels:** <labels>
- **Project:** Added to project board (Todo)
```

## Error Handling

- **Empty argument**: Show usage instructions
- **CLAUDE.md missing project config**: Ask user to add the `## GitHub Project` section
- **`gh` not authenticated**: "Please authenticate with: `gh auth login`"
- **Issue creation failed**: Show the error from `gh`
- **Project item-add failed**: Issue was created successfully but couldn't be added to the project — show issue URL and suggest manual addition
- **Label doesn't exist**: `gh` will create it automatically; if it fails, retry without the invalid label and warn
