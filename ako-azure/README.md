# ako-azure

Pull request review and git-ops monitoring for Azure DevOps, using the [Tiberriver256/mcp-server-azure-devops](https://github.com/Tiberriver256/mcp-server-azure-devops) MCP server.

## Scope


It can use any tool exposed by the Azure DevOps MCP server, including:
- Projects
- Repositories and file content/tree
- Branch and commit operations
- Pull requests (list, inspect, comment, update, checks)
- Work items (list/get/create/update/link)
- Search (code, wiki, work items)
- Pipelines (list, run, logs, timeline, artifacts)
- Wiki operations

It does **not** do static/security scanning (SAST/SCA). Pair with a scanner MCP (for example Semgrep or Snyk) if you need real vulnerability analysis.

## Requirements

- Your Azure DevOps instance must be reachable from the machine running Claude Desktop — for an on-prem Azure DevOps Server behind VPN, connect the VPN **before** launching Claude Desktop so the MCP server process inherits the network route.
- Node.js / npx available on the machine.
- A Personal Access Token (PAT) with enough permissions for the operations you want. For read-only usage, start with read scopes. For create/update actions (PR comments, work item changes, pipeline triggers, commits), grant the corresponding write scopes.

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
| `AZURE_DEVOPS_ORG_URL` | Yes | Your ADO Server/collection URL. No default is baked in; each installer sets their own. |
| `AZURE_DEVOPS_PAT` | Yes | Personal Access Token. On-prem Azure DevOps Server supports PAT auth. |
| `AZURE_DEVOPS_DEFAULT_PROJECT` | Recommended | Used automatically when a request doesn't name a project. Explicit project names in user requests still take priority. |
| `AZURE_DEVOPS_AUTH_METHOD` | Yes | Keep as `pat` for Azure DevOps Server (on-prem). |

Each colleague who installs this plugin creates their **own** local `.env` with their **own** PAT — never share a `.env` file or a PAT between users, since actions taken through this plugin are attributed to whichever PAT is configured.

## Testing locally

After creating `.env`, restart Claude Desktop (with VPN connected) and try:
- "List projects" → should return accessible projects
- "List repositories in <project>" → should return repos
- "List active pull requests" → should return PRs from the default or specified project
- "Get work item <id>" → should return work item details
- "List pipelines" → should return pipeline definitions
- "Search code for <term> in <project>" → should return matches

If these fail with an auth error, check PAT permissions and that `.env` was saved in the right folder. If they time out, check the VPN route was active when Claude Desktop started the server.
