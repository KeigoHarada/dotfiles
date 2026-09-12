[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArgs
)

# 管理者権限チェック & 自動昇格
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "==> 管理者権限で実行します (UAC昇格)..." -ForegroundColor Cyan
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($ScriptArgs) {
        $argList += " " + ($ScriptArgs -join " ")
    }
    $process = Start-Process powershell.exe -Verb RunAs -ArgumentList $argList -PassThru -Wait
    exit $process.ExitCode
}

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
