@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0installer\Install.ps1"
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" echo Installation failed with error %RC%. Read the message above.
pause
exit /b %RC%
