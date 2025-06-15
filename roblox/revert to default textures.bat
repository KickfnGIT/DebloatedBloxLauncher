@echo off
setlocal EnableDelayedExpansion

:: Elevate to admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set paths
set "LOCALAPPDATA=%LOCALAPPDATA%"
set "USERDOCS=%USERPROFILE%\Documents"
set "VERSIONS_DIR=%LOCALAPPDATA%\Roblox\Versions"

:: Find latest version-* folder
for /f "delims=" %%A in ('dir /b /ad "%VERSIONS_DIR%\version-*" ^| sort /R') do (
    set "VERSION_FOLDER=%%A"
    goto :found
)

:found
if not defined VERSION_FOLDER (
    echo ❌ Roblox version folder not found.
    pause
    exit /b
)

set "ROBLOX_DEST=%VERSIONS_DIR%\%VERSION_FOLDER%\PlatformContent\pc\textures"

:: Download ZIP and extract
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "ZIP_FILE=%TEMP%\blox.zip"
set "UNZIP_DIR=%TEMP%\blox_extracted"

echo Downloading...
curl -L -o "!ZIP_FILE!" "!ZIP_URL!"
if not exist "!ZIP_FILE!" (
    echo ❌ Download failed.
    pause
    exit /b
)

echo Extracting...
powershell -Command "Expand-Archive -LiteralPath '!ZIP_FILE!' -DestinationPath '!UNZIP_DIR!' -Force"

:: Install to Roblox
if exist "!ROBLOX_DEST!" rd /s /q "!ROBLOX_DEST!"
xcopy /s /e /y "!UNZIP_DIR!\DebloatedBloxLauncher-main\roblox\Default textures" "!ROBLOX_DEST!\"

:: Install to Voidstrap, Bloxstrap, Fishstrap mods
for %%D in ("Voidstrap\Mods" "Bloxstrap\Modifications" "Fishstrap\Modifications") do (
    set "MODROOT=%LOCALAPPDATA%\%%~D\PlatformContent\pc\textures"
    if exist "!MODROOT!\.." (
        echo Installing to %%~D...
        rd /s /q "!MODROOT!" >nul 2>&1
        mkdir "!MODROOT!\.." >nul 2>&1
        xcopy /s /e /y "!ROBLOX_DEST!" "!MODROOT!\"
    )
)

:: Clean up Documents\roblox (preserve skyboxfix)
set "DOC_ROBLOX=%USERDOCS%\roblox"
set "DOC_TEXTURES=%DOC_ROBLOX%\textures"
if exist "!DOC_ROBLOX!" (
    echo Cleaning up Documents\roblox...
    for /d %%F in ("!DOC_ROBLOX!\*") do (
        if /i not "%%~nxF"=="skyboxfix" (
            echo Deleting %%~nxF
            rd /s /q "%%F"
        )
    )
    echo Installing textures to Documents\roblox...
    mkdir "!DOC_TEXTURES!" >nul 2>&1
    xcopy /s /e /y "!ROBLOX_DEST!" "!DOC_TEXTURES!\"
)

:: Final cleanup
rd /s /q "!UNZIP_DIR!" >nul 2>&1
del "!ZIP_FILE!" >nul 2>&1

echo ✅ Textures installed and Documents\roblox cleaned.
pause
exit