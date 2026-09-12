@echo off
setlocal

:: 管理者権限チェック & 自動昇格
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ==> 管理者権限で実行します (UAC昇格)...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -Verb RunAs -ArgumentList '/c `\"%~f0`\" %*' -Wait"
    exit /b %ERRORLEVEL%
)

where py >nul 2>nul
if %ERRORLEVEL% equ 0 (
    py -3 "%~dp0dotfiles" %*
    exit /b %ERRORLEVEL%
)
where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    python "%~dp0dotfiles" %*
    exit /b %ERRORLEVEL%
)
where python3 >nul 2>nul
if %ERRORLEVEL% equ 0 (
    python3 "%~dp0dotfiles" %*
    exit /b %ERRORLEVEL%
)
echo [ERROR] Python not found. Please install Python.
exit /b 1
