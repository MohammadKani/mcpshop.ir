---
name: ako-azure
description: Use the connected Azure DevOps MCP server (Tiberriver256/mcp-server-azure-devops) to list, inspect, and review pull requests, manage reviewers, read/post PR comments, and perform other git-ops operations against Azure DevOps Repos. Use this skill whenever the user mentions pull requests, PRs, merges, code review, reviewers, diffs, branches, or repos in the context of Azure DevOps — including requests to list active PRs, review or comment on a specific PR, check PR status, add/remove reviewers, or configure the ako-azure MCP server. Do not use this skill for Work Items, Epics, Boards, or Sprints — that is handled by the separate ako-ado skill.
version: 0.1.0
---

# AKO Azure DevOps Git-Ops (ako-azure)

Use the bundled Tiberriver256 Azure DevOps MCP server as the interface for Git repo and pull request operations. This skill is scoped to Repos/PRs only — it is the git-ops counterpart to `ako-ado`, which handles Work Items and Boards. Do not duplicate work-item queries here; route those to `ako-ado` instead.

## When to Use

Use this skill when the user wants to:

- list pull requests (all, active, completed, abandoned, or filtered by creator/reviewer/branch)
- fetch details or the diff for a specific pull request
- read comments/threads on a pull request
- post a comment or review note on a pull request
- add or remove reviewers on a pull request
- update a pull request's title, description, status, or draft state
- check whether a PR is waiting on their review, or waiting on someone else's
- perform other repo-level git-ops (list repos, branches) exposed by the server

## Project Scope

The server is configured with a default project via `AZURE_DEVOPS_DEFAULT_PROJECT`. Use that default automatically when the user does not name a project. If the user mentions a different project explicitly (by name), use the one they mention instead of the default for that request — do not silently override an explicit mention with the default.

## Primary References

- [Server README](../../.mcp.json) — server command and required environment variables
- Upstream project: Tiberriver256/mcp-server-azure-devops — check its tool list directly if a requested operation isn't covered below; do not assume a capability exists without confirming.

## Workflow

### Listing & Finding Pull Requests

1. **List active PRs** → use the list-pull-requests tool with status filter `active`
2. **My review queue** → filter by reviewer = current user, status `active`
3. **By branch** → filter by source/target branch when the user names one
4. **By creator** → filter by creator when the user asks "PRs opened by X"

### Reviewing a Pull Request

1. **Get details/diff** → fetch the PR by ID before commenting or summarizing; never guess at file changes
2. **Read existing comments** → fetch threads before adding a new comment, so you don't duplicate feedback already given
3. **Post a comment** → add the comment tied to the specific PR ID (and file/line if the tool supports it)
4. **Summarize for the user** → when asked to "review this PR," read the diff and existing thread first, then give a structured assessment (see Output Format), rather than a one-line reaction

### Managing Reviewers & Status

1. **Add/remove reviewers** → use the reviewer-management tool with explicit reviewer identities the user names
2. **Update PR** → change title, description, draft state, or status only on explicit instruction; do not mark a PR complete/abandoned unless the user clearly asked for that

## Output Format

Present results in **human-readable format by default**:

- **PR list** → table or bullet list with PR ID, title, author, source→target branch, status, reviewer vote state
- **Single PR** → ID, title, author, branches, status, and a short diff summary
- **Review output** → structured findings grouped by file, each with a short explanation, not just a verdict
- **Comments/threads** → author, timestamp, text, in chronological order
- **Confirmations** → acknowledge the action taken with the PR ID (e.g., "Comment posted on PR #482")

If the user asks for raw JSON, provide that instead.

## Important Behavior

- Treat Azure DevOps REST responses as source of truth — never invent PR IDs, reviewer names, or statuses
- This skill does not perform static/security scanning (SAST/SCA) — it only reads and comments through Azure DevOps. If the user wants an actual vulnerability scan, tell them that's a separate tool (e.g. a Semgrep/Snyk MCP) and do not claim to have found real CVEs from code inspection alone
- Always state the PR ID prominently — it's the reference for any follow-up action
- Confirm destructive or state-changing actions (status change, reviewer removal) before assuming intent, if the request is ambiguous
- If a requested capability isn't in the server's tool list, say so rather than fabricating a result
