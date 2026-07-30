# ako-azure

Pull request review and git-ops monitoring for Azure DevOps, using the [Tiberriver256/mcp-server-azure-devops](https://github.com/Tiberriver256/mcp-server-azure-devops) MCP server.

## Scope

This plugin covers **Repos and Pull Requests only** — listing PRs, reading diffs and comments, posting review comments, managing reviewers, and updating PR status.

It does **not** cover:
- Work Items, Epics, Boards, Sprints — that's the separate `ako-ado` plugin
- Static/security scanning (SAST/SCA) — pair this with a dedicated scanner (e.g. a Semgrep or Snyk MCP) if you want real vulnerability detection; this plugin only reads/comments through Azure DevOps, it does not scan code for CVEs

## Requirements

- Your Azure DevOps instance must be reachable from the machine running Claude Desktop — for an on-prem Azure DevOps Server behind VPN, connect the VPN **before** launching Claude Desktop so the MCP server process inherits the network route.
- Node.js / npx available on the machine.
- A Personal Access Token (PAT) with at minimum **Code (Read)** scope. Add **Code (Read & Write)** if you want this plugin to post comments or change PR status, not just read.

## Setup — where to put your credentials

Do **not** edit `.mcp.json` and do not set these as Windows/system environment variables or in VS Code. Both would either not be picked up or risk leaking your PAT into git if this plugin folder is ever committed/pushed.

Instead, create a plain-text file named `.env` **in this same folder** (`ako-azure/.env`, next to this README) with your real values:

1. Copy `.env.example` to a new file named `.env` in this folder.
2. Edit `.env` and fill in your real values:

```
AZURE_DEVOPS_ORG_URL=https://vcontrol.sepasholding.com/YourCollection
AZURE_DEVOPS_AUTH_METHOD=pat
AZURE_DEVOPS_PAT=your-real-personal-access-token
AZURE_DEVOPS_DEFAULT_PROJECT=YourProject
```

3. Save it. `.mcp.json` is wired to load this `.env` file automatically (via `dotenv-cli`) before starting the server — you don't need to touch `.mcp.json` at all.
4. `.env` is listed in `.gitignore` in this folder, so it will never be committed or pushed to the marketplace repo. Never remove it from `.gitignore`, and never paste your PAT anywhere else (chat, marketplace.json, plugin.json).

| Variable | Required | Notes |
|---|---|---|
| `AZURE_DEVOPS_ORG_URL` | Yes | Your ADO Server/collection URL. No default is baked in — every installer sets their own. |
| `AZURE_DEVOPS_PAT` | Yes | Personal Access Token. On-prem Azure DevOps Server only supports PAT auth (not Azure Identity/CLI login). |
| `AZURE_DEVOPS_DEFAULT_PROJECT` | Recommended | Used automatically when a request doesn't name a project. You can still mention a different project by name in a request and it will be used instead of this default. |
| `AZURE_DEVOPS_AUTH_METHOD` | Yes | Keep as `pat`. |

Each colleague who installs this plugin creates their **own** local `.env` with their **own** PAT — never share a `.env` file or a PAT between users, since actions taken through this plugin are attributed to whichever PAT is configured.

## Testing locally

After creating `.env`, restart Claude Desktop (with VPN connected) and try:
- "List active pull requests" → should return PRs from the default project
- "Show me PR #<id>" → should return details/diff for a specific PR
- "What comments are on PR #<id>?" → should return the thread
- "Add a comment on PR #<id> saying ..." → should post and confirm the PR ID

If these fail with an auth error, check the PAT scope and that `.env` was saved in the right folder. If they time out, check the VPN route was active when Claude Desktop started the server.
