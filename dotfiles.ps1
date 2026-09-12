# 管理者権限チェック (SSHセッション時はUACダイアログを出せないためスキップ)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    if ($env:SSH_CONNECTION -or -not [Environment]::UserInteractive) {
        Write-Warning "SSHセッションのためUAC昇格はスキップします（管理者権限が必要な場合は管理者アカウントでSSH接続してください）。"
    } else {
        Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $args"
        exit
    }
}

if (Get-Command py -ErrorAction SilentlyContinue) {
    py -3 "$PSScriptRoot\dotfiles" $args
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    python "$PSScriptRoot\dotfiles" $args
} else {
    # PATHに反映されていない場合、レジストリからPATHを再読み込みして再試行
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    if (Get-Command py -ErrorAction SilentlyContinue) {
        py -3 "$PSScriptRoot\dotfiles" $args
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        python "$PSScriptRoot\dotfiles" $args
    } else {
        Write-Error "[ERROR] Python が見つかりません。一度 SSH を再接続するか、PATH を確認してください。"
        exit 1
    }
}
