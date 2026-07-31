---
name: ako-azure
description: Use the connected Azure DevOps MCP servers to handle all Azure DevOps work: pull requests, reviewers, PR comments, repos, branches, wikis, pipelines — and, by delegating to the ako-ado tool set, work items, boards, sprints, and WIQL queries. Use this skill whenever the user mentions Azure DevOps, ADO, pull requests, PRs, merges, code review, repos, branches, pipelines, wikis, work items, epics, boards, or sprints. This is now the single entry point for Azure DevOps — it covers git-ops natively and routes work-item/board requests to the ako-ado tool set internally.
version: 0.3.0
---

# AKO Azure DevOps (ako-azure)

Single entry point for all Azure DevOps work. Two MCP servers are connected under the hood:

- **mcp__AKO_Azure__*** (Tiberriver256/mcp-server-azure-devops) — repos, pull requests, reviewers, PR comments, wikis, pipelines.
- **mcp__AKO_ADO__*** — work items, boards, sprints, WIQL.

You don't need to know which server backs which request — this skill routes internally. Treat both tool sets as available whenever this skill is active.

## When to Use

Use this skill whenever the user wants to:

- list or inspect projects, repositories, branches, commits, trees, or files
- create or update branches, commits, pull requests, reviewers, or PR comments
- inspect pull request details, diffs, checks, reviews, and discussion threads
- list/get/trigger pipelines and inspect runs, logs, timelines, and artifacts
- list/read/create/update/search wiki pages
- inspect, create, or update work items
- query board views, move work items across columns, check personal work queues
- run WIQL queries or retrieve work item types

## Routing table

**Handled natively by mcp__AKO_Azure__*:**
- List/get/create/update pull requests, PR diffs, PR checks
- Add/remove reviewers, post/read PR comments and threads, update thread status
- List repos, branches, commits, repo tree, search code
- Wikis: list, create, read, update, search wiki pages
- Pipelines: list, get, trigger, run status, logs, artifacts
- Work item CRUD by ID (get/list/create/update/search a single work item, comments, links) — AKO_Azure also exposes these directly

**Delegated to mcp__AKO_ADO__* (no native AKO_Azure equivalent):**
- Board views: `ado_list_boards`, `ado_list_board_columns`
- Moving cards across a board: `ado_move_work_items_to_board_column`, `ado_move_all_items_between_board_columns`
- "My work items" queries: `ado_my_work_items`
- WIQL queries: `ado_query_wiql`
- Listing valid work item types for the project: `ado_list_work_item_types`

When a request needs one of the delegated operations above, call the corresponding `mcp__AKO_ADO__*` tool directly — don't tell the user to switch skills, just use it.

## Primary References

- [Server config](../../.mcp.json) — server command and required environment variables
- Upstream Azure MCP capability source: Tiberriver256/mcp-server-azure-devops

## Project Scope

The server is configured with a default project via `AZURE_DEVOPS_DEFAULT_PROJECT`. Use that default automatically when the user does not name a project. If the user mentions a different project explicitly, use the one they mention instead of the default for that request.

## Workflow

### Establish Context
1. Run a lightweight context check when needed (project, repositories, current user, default project)
2. Confirm identifiers before stateful operations (project, repository, PR ID, work item ID, pipeline ID)
3. Prefer explicit user-provided identifiers over inferred guesses

### Listing & Finding Pull Requests
1. **List active PRs** → list-pull-requests tool, status filter `active`
2. **My review queue** → filter by reviewer = current user, status `active`
3. **By branch** → filter by source/target branch when named
4. **By creator** → filter by creator when asked "PRs opened by X"

### Reviewing a Pull Request
1. **Get details/diff** → fetch the PR by ID before commenting or summarizing; never guess at file changes
2. **Read existing comments** → fetch threads before adding a new comment
3. **Post a comment** → tie it to the specific PR ID (and file/line if supported)
4. **Summarize for the user** → read the diff and thread first, then give a structured assessment, not a one-line reaction

### Managing Reviewers & Status
1. **Add/remove reviewers** → use explicit reviewer identities the user names
2. **Update PR** → change title/description/draft/status only on explicit instruction; never mark a PR complete/abandoned unless clearly asked

### Work Items & Boards
1. **Single work item lookup/update** → use AKO_Azure's work item tools
2. **Board state, moving cards, "what's in my queue", custom queries** → use the AKO_ADO tools listed in the routing table above
3. **Never fabricate a WIQL query result or board state** — always call the tool

### Pipelines
1. **List/get** → identify the exact pipeline before acting
2. **Runs/timeline/logs** → inspect latest failing run before conclusions
3. **Trigger** → run with explicit branch/parameters when requested

### Repositories and Search
1. **Repo inspection** → list repositories, then inspect file/tree/content as requested
2. **Search** → use project/repo-scoped queries first, broaden only when needed

### State-Changing Actions
1. **PR/work item/wiki updates** → apply only what the user asked to change
2. **Reviewer removal, status changes, board moves, pipeline triggers** → confirm intent if ambiguous
3. **Report outcomes** → include IDs and key changed fields for follow-up

## Output Format

Human-readable by default:
- **PR list** → table/bullet list with PR ID, title, author, source→target branch, status, reviewer vote state
- **Single PR** → ID, title, author, branches, status, short diff summary
- **Review output** → structured findings grouped by file, not just a verdict
- **Comments/threads** → author, timestamp, text, chronological
- **Board/work item results** → work item ID, title, state, assignee; board results grouped by column
- **Pipelines** → pipeline ID/name, latest run status, start/end time, key failed stage/job when available
- **Repository/file queries** → repository, branch/ref, path/query scope, and returned content summary
- **Confirmations** → acknowledge the action taken with the relevant ID (e.g., "Comment posted on PR #482", "Moved WI #1204 to In Progress")

If the user asks for raw JSON, provide that instead.

## Important Behavior

- Treat Azure DevOps REST responses as source of truth — never invent PR IDs, work item IDs, reviewer names, board states, or statuses
- If a requested capability exists in AKO_ADO but not AKO_Azure, route to AKO_ADO automatically without asking the user to switch skills
- This skill does not perform static/security scanning (SAST/SCA) — if the user wants an actual vulnerability scan, say that's a separate tool and don't claim to have found real CVEs from code inspection alone
- Always state the PR ID or work item ID prominently — it's the reference for any follow-up action
- Confirm destructive or state-changing actions (status change, reviewer removal, board moves) before assuming intent, if the request is ambiguous
- If a requested capability isn't in either server's tool list, say so rather than fabricating a result
