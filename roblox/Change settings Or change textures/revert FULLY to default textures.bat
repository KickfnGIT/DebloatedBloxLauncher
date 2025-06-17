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
set "DBL_PATH=%LOCALAPPDATA%\DBL"
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

:: Clean up DBL folder (preserve skyboxfix and Change settings Or change textures)
if exist "!DBL_PATH!" (
    echo Cleaning up DBL folder...
    for /d %%F in ("!DBL_PATH!\*") do (
        set "FOLDER=%%~nxF"
        if /i not "!FOLDER!"=="skyboxfix" if /i not "!FOLDER!"=="Change settings Or change textures" (
            echo Deleting !FOLDER!
            rd /s /q "%%F"
        )
    )
    echo Installing textures to DBL...
    mkdir "!DBL_PATH!\Default textures" >nul 2>&1
    xcopy /s /e /y "!ROBLOX_DEST!" "!DBL_PATH!\Default textures\"
)

:: Final cleanup
rd /s /q "!UNZIP_DIR!" >nul 2>&1
del "!ZIP_FILE!" >nul 2>&1

echo ✅ Textures installed and DBL folder cleaned.
exit