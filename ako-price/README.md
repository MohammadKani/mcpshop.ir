# ako-price (plugin)

Skill-only plugin — **no MCP server**. Fetches today's USD, gold, and coin
(سکه) prices directly from `baha24.com` via the web-fetch tool and reports
them in a fixed, standardized format (Persian RTL table + canonical JSON).

## Components

- **Skill** (`skills/ako-price/SKILL.md`) — the six required instruments
  (دلار, انس طلا, گرم طلا, سکه امامی, نیم سکه, ربع سکه), a fixed
  round-half-up rounding rule, and an unchanging output schema. Claude does
  the extraction, rounding, and formatting itself — no script, no server.

## Setup

Nothing to install or configure — no environment variables, no build step, no
external service other than a live fetch of `https://baha24.com/` at request
time.

## Usage

Ask for قیمت دلار / قیمت طلا / قیمت سکه / نرخ ارز / a daily price report — the
skill fetches fresh prices and returns the fixed table + JSON. It never uses
cached or remembered prices.

## Note on the retired `ako-prices-py` variant

`skills/ako-prices-py` (a near-duplicate that offloaded rounding to a Python
script, `scripts/format_prices.py`, for stricter determinism) was **not**
packaged as a plugin — per your direction, this `ako-price` (pure-Claude,
no script dependency) version was kept as the one going forward. The
`ako-prices-py` folder itself was left untouched in `skills/`; nothing there
was deleted.

## Not related to `ako-pargar-mcp-server`

This skill/plugin has no relationship to the Pargar (Fonix Mailbox2) MCP
server — it doesn't call any `pargar_*` tool, and never did. See the
`ako-pargar` plugin for that server's (newly authored) skill.
