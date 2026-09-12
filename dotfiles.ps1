[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArgs
)

$scriptPath = Join-Path $PSScriptRoot "dotfiles"

if (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3 $scriptPath @ScriptArgs
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    & python $scriptPath @ScriptArgs
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    & python3 $scriptPath @ScriptArgs
} else {
    Write-Error "[ERROR] Python not found. Please install Python."
    exit 1
}
