@echo off
setlocal
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
