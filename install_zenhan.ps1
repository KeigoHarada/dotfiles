# ====================================================================
# 設定
# ====================================================================
$ZenhanVersion = "0.0.4"
$ZenhanUrl = "https://github.com/iuchia/zenhan/releases/download/v${ZenhanVersion}/zenhan.zip"
$InstallDir = "$env:LOCALAPPDATA\zenhan"
$ZipPath = "$env:TEMP\zenhan.zip"

# ====================================================================
# ダウンロード
# ====================================================================
Write-Host "zenhan をダウンロード中..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $ZenhanUrl -OutFile $ZipPath -UseBasicParsing

# ====================================================================
# 展開
# ====================================================================
Write-Host "展開中: $InstallDir" -ForegroundColor Cyan
if (Test-Path $InstallDir) {
  Remove-Item $InstallDir -Recurse -Force
}
Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force

# ====================================================================
# PATH に追加 (ユーザー環境変数)
# ====================================================================
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($CurrentPath -notlike "*$InstallDir*") {
  Write-Host "PATH に追加中..." -ForegroundColor Cyan
  [Environment]::SetEnvironmentVariable(
    "Path",
    "$CurrentPath;$InstallDir",
    "User"
  )
  Write-Host "PATH に追加しました: $InstallDir" -ForegroundColor Green
} else {
  Write-Host "PATH にすでに登録済みです" -ForegroundColor Yellow
}

# ====================================================================
# 動作確認
# ====================================================================
Write-Host "`n動作確認..." -ForegroundColor Cyan
$ZenhanExe = Join-Path $InstallDir "zenhan.exe"

if (Test-Path $ZenhanExe) {
  Write-Host "zenhan.exe が見つかりました: $ZenhanExe" -ForegroundColor Green
  & $ZenhanExe 0 # 英語モードで確認
  Write-Host "インストール完了！" -ForegroundColor Green
} else {
  Write-Host "zenhan.exe が見つかりません。zipの中身を確認してください。" -ForegroundColor Red
  Write-Host "zipの内容:" -ForegroundColor Yellow
  Get-ChildItem $InstallDir -Recurse | Select-Object FullName
}

# ====================================================================
# 後片付け
# ====================================================================
Remove-Item $ZipPath -Force
Write-Host "`n完了。新しいターミナルを開くと PATH が有効になります。" -ForegroundColor Cyan
