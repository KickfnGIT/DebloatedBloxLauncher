@echo off
setlocal EnableDelayedExpansion

:: Elevate to admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Detect current user's local path
set "LOCALAPPDATA=%LOCALAPPDATA%"
set "VERSIONS_DIR=%LOCALAPPDATA%\Roblox\Versions"
for /f "delims=" %%A in ('dir /b /ad "%VERSIONS_DIR%\version-*" ^| sort /R') do (
    set "VERSION_FOLDER=%%A"
    goto :found
)

:found
if not defined VERSION_FOLDER (
    echo Could not find any version-* folder in: %VERSIONS_DIR%
    pause
    exit /b
)

set "FULL_VERSION_PATH=%VERSIONS_DIR%\%VERSION_FOLDER%\PlatformContent\pc"
set "DEST_FOLDER=%FULL_VERSION_PATH%\textures"

:: Clean destination if it already exists
if exist "%DEST_FOLDER%" (
    echo Removing old textures folder...
    rd /s /q "%DEST_FOLDER%"
)

:: Download and extract
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "ZIP_PATH=%TEMP%\blox.zip"
set "EXTRACT_PATH=%TEMP%\blox_extracted"

echo Downloading repo ZIP...
curl -L -o "!ZIP_PATH!" "!ZIP_URL!"
if not exist "!ZIP_PATH!" (
    echo Download failed!
    pause
    exit /b
)

echo Extracting ZIP...
powershell -Command "Expand-Archive -LiteralPath '!ZIP_PATH!' -DestinationPath '!EXTRACT_PATH!' -Force"

echo Copying Default textures as 'textures'...
xcopy /s /e /y "!EXTRACT_PATH!\DebloatedBloxLauncher-main\roblox\Default textures" "!DEST_FOLDER!\"

:: Cleanup
rd /s /q "!EXTRACT_PATH!" >nul 2>&1
del "!ZIP_PATH!" >nul 2>&1

echo ✅ Done! 'textures' folder is now at:
echo    !DEST_FOLDER!
pause