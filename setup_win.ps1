# ==========================================
# Windows Environment Setup Script
# ==========================================

# コンソール出力の文字化け防止
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Section {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

# 管理者権限チェック
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-Not $isAdmin) {
    Write-Warn "このスクリプトは管理者権限で実行されていないため、一部のシンボリックリンク作成が失敗する可能性があります。"
}

# ==========================================
# 1. WezTerm のインストールと設定
# ==========================================
Write-Section "WezTerm"

if (Get-Command wezterm -ErrorAction SilentlyContinue) {
    Write-Warn "WezTerm は既にインストール済みです"
} else {
    Write-Info "WezTerm をインストール中..."
    # WinGet を使用してインストール
    winget install wezterm --accept-package-agreements --accept-source-agreements
    if ($?) {
        Write-Success "WezTerm をインストールしました"
    } else {
        Write-Host "[ERROR] WezTerm のインストールに失敗しました" -ForegroundColor Red
    }
}

Write-Info "WezTerm の設定ファイルを配置します..."
$weztermConfigDir = "$env:USERPROFILE\.config\wezterm"
$dotfilesWeztermConfig = "$env:USERPROFILE\dotfiles\.config\wezterm\wezterm.lua"

if (-Not (Test-Path $weztermConfigDir)) {
    New-Item -ItemType Directory -Force -Path $weztermConfigDir | Out-Null
}

Copy-Item -Path $dotfilesWeztermConfig -Destination "$weztermConfigDir\wezterm.lua" -Force
Write-Success "WezTerm の設定ファイルをコピーしました"

# ==========================================
# 2. JetBrainsMono Nerd Font のインストール
# ==========================================
Write-Section "JetBrainsMono Nerd Font"

Write-Info "JetBrainsMono Nerd Font をインストール中..."
winget install --id DEVCOM.JetBrainsMonoNerdFont --accept-package-agreements --accept-source-agreements
if ($?) {
    Write-Success "JetBrainsMono Nerd Font のインストール処理が完了しました"
} else {
    Write-Warn "JetBrainsMono Nerd Font のインストールに失敗したか、既にインストールされています"
}

Write-Section "Summary"
Write-Success "Windows環境のセットアップが完了しました！"
Write-Info "必要に応じてターミナルを再起動してください。"
