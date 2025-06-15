@echo off
setlocal EnableDelayedExpansion

:: Elevate to admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set environment variables
set "LOCALAPPDATA=%LOCALAPPDATA%"
set "VERSIONS_DIR=%LOCALAPPDATA%\Roblox\Versions"

:: Detect latest Roblox version folder
for /f "delims=" %%A in ('dir /b /ad "%VERSIONS_DIR%\version-*" ^| sort /R') do (
    set "VERSION_FOLDER=%%A"
    goto :found
)

:found
if not defined VERSION_FOLDER (
    echo ❌ Could not find a Roblox version folder.
    pause
    exit /b
)

set "FULL_VERSION_PATH=%VERSIONS_DIR%\%VERSION_FOLDER%\PlatformContent\pc"
set "DEST_FOLDER=!FULL_VERSION_PATH!\textures"

:: Clear existing textures if present
if exist "!DEST_FOLDER!" (
    echo Removing old Roblox textures...
    rd /s /q "!DEST_FOLDER!"
)

:: Download ZIP
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "ZIP_PATH=%TEMP%\blox.zip"
set "EXTRACT_PATH=%TEMP%\blox_extracted"

echo Downloading from GitHub...
curl -L -o "!ZIP_PATH!" "!ZIP_URL!"
if not exist "!ZIP_PATH!" (
    echo ❌ Download failed!
    pause
    exit /b
)

echo Extracting archive...
powershell -Command "Expand-Archive -LiteralPath '!ZIP_PATH!' -DestinationPath '!EXTRACT_PATH!' -Force"

:: Copy textures to Roblox
echo Installing to Roblox: !DEST_FOLDER!
xcopy /s /e /y "!EXTRACT_PATH!\DebloatedBloxLauncher-main\roblox\Default textures" "!DEST_FOLDER!\"

:: Also install to compatible mod systems
for %%S in ("Voidstrap\Mods" "Bloxstrap\Modifications" "Fishstrap\Modifications") do (
    set "MOD_BASE=%LOCALAPPDATA%\%%~S"
    set "MOD_TARGET=!MOD_BASE!\PlatformContent\pc\textures"
    if exist "!MOD_BASE!" (
        echo Installing to %%~S...
        rd /s /q "!MOD_TARGET!" >nul 2>&1
        mkdir "!MOD_BASE!\PlatformContent\pc" 2>nul
        xcopy /s /e /y "!DEST_FOLDER!" "!MOD_TARGET!\"
    )
)

:: Clean temp files
echo Cleaning up...
rd /s /q "!EXTRACT_PATH!" >nul 2>&1
del "!ZIP_PATH!" >nul 2>&1

echo ✅ All done! Textures installed to Roblox and available mod platforms.
pause