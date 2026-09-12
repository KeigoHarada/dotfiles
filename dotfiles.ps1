# 管理者権限がなければ昇格して再実行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $args"
    exit
}

if (Get-Command py -ErrorAction SilentlyContinue) {
    py -3 "$PSScriptRoot\dotfiles" $args
} else {
    python "$PSScriptRoot\dotfiles" $args
}
