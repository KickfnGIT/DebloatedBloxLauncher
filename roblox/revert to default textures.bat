@echo off
setlocal EnableDelayedExpansion

:: Elevate to admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set key environment paths
set "LOCALAPPDATA=%LOCALAPPDATA%"
set "VERSIONS_DIR=%LOCALAPPDATA%\Roblox\Versions"

:: Find latest version-* folder
for /f "delims=" %%A in ('dir /b /ad "%VERSIONS_DIR%\version-*" ^| sort /R') do (
    set "VERSION_FOLDER=%%A"
    goto :found
)

:found
if not defined VERSION_FOLDER (
    echo ❌ Could not find any Roblox version folder.
    pause
    exit /b
)

set "FULL_VERSION_PATH=%VERSIONS_DIR%\%VERSION_FOLDER%\PlatformContent\pc"
set "DEST_FOLDER=!FULL_VERSION_PATH!\textures"

:: Remove existing Roblox textures folder
if exist "!DEST_FOLDER!" (
    echo Removing existing Roblox textures...
    rd /s /q "!DEST_FOLDER!"
)

:: Prepare for ZIP download and extraction
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "ZIP_PATH=%TEMP%\blox.zip"
set "EXTRACT_PATH=%TEMP%\blox_extracted"

echo Downloading ZIP from GitHub...
curl -L -o "!ZIP_PATH!" "!ZIP_URL!"
if not exist "!ZIP_PATH!" (
    echo ❌ Download failed!
    pause
    exit /b
)

echo Extracting ZIP...
powershell -Command "Expand-Archive -LiteralPath '!ZIP_PATH!' -DestinationPath '!EXTRACT_PATH!' -Force"

:: Copy textures to Roblox version folder
echo Installing textures to Roblox install...
xcopy /s /e /y "!EXTRACT_PATH!\DebloatedBloxLauncher-main\roblox\Default textures" "!DEST_FOLDER!\"

:: Also install to Voidstrap and Bloxstrap if paths exist
for %%D in ("Voidstrap\Mods" "Bloxstrap\Modifications") do (
    set "MOD_BASE=%LOCALAPPDATA%\%%D"
    set "MOD_TARGET=!MOD_BASE!\PlatformContent\pc\textures"
    if exist "!MOD_BASE!" (
        echo Installing textures to %%D...
        rd /s /q "!MOD_TARGET!" >nul 2>&1
        mkdir "!MOD_BASE!\PlatformContent\pc" 2>nul
        xcopy /s /e /y "!DEST_FOLDER!" "!MOD_TARGET!\"
    )
)

:: Cleanup
echo Cleaning up temp files...
rd /s /q "!EXTRACT_PATH!" >nul 2>&1
del "!ZIP_PATH!" >nul 2>&1

echo ✅ All done! Textures installed where needed.
pause