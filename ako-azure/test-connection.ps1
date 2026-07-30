# Standalone connectivity/credential check for ako-azure.
# Run this DIRECTLY on your Windows machine (PowerShell) with VPN connected,
# BEFORE testing through Claude Desktop. It bypasses the MCP server entirely
# and calls the Azure DevOps REST API directly with your .env values.

$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: .env not found at $envFile" -ForegroundColor Red
    exit 1
}

$vars = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $parts = $_ -split '=', 2
    $vars[$parts[0].Trim()] = $parts[1].Trim()
}

$orgUrl  = $vars["AZURE_DEVOPS_ORG_URL"]
$pat     = $vars["AZURE_DEVOPS_PAT"]
$project = $vars["AZURE_DEVOPS_DEFAULT_PROJECT"]

if (-not $orgUrl -or -not $pat) {
    Write-Host "ERROR: AZURE_DEVOPS_ORG_URL or AZURE_DEVOPS_PAT missing from .env" -ForegroundColor Red
    exit 1
}

Write-Host "Testing: $orgUrl" -ForegroundColor Cyan

$pair = ":$pat"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{ Authorization = "Basic $base64" }

try {
    $resp = Invoke-RestMethod -Uri "$orgUrl/_apis/projects?api-version=7.0" -Headers $headers -Method Get -TimeoutSec 10
    Write-Host "SUCCESS: reached Azure DevOps, PAT is valid." -ForegroundColor Green
    Write-Host "Projects visible to this PAT:" -ForegroundColor Green
    $resp.value | ForEach-Object { Write-Host " - $($_.name)" }
    if ($project) {
        if ($resp.value.name -contains $project) {
            Write-Host "Default project '$project' found and accessible." -ForegroundColor Green
        } else {
            Write-Host "WARNING: default project '$project' not in the list above - check spelling/access." -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "If this times out: check VPN is connected." -ForegroundColor Yellow
    Write-Host "If this returns 401/403: check the PAT value/scope (needs Code Read)." -ForegroundColor Yellow
    Write-Host "If this returns 404: check AZURE_DEVOPS_ORG_URL (collection name/path)." -ForegroundColor Yellow
}
