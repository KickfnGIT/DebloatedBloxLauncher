@echo off
setlocal enabledelayedexpansion

:: === Define URLs and paths ===
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "TEMP_ZIP=%TEMP%\sky_textures.zip"
set "TEMP_DIR=%TEMP%\sky_textures"
set "EXTRACTED_SKY=%TEMP_DIR%\DebloatedBloxLauncher-main\roblox\Default textures"
set "TARGET_ROOT=C:\Users\steve\Documents\roblox"

:: === Download sky textures zip ===
echo Downloading sky textures...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ZIP_URL%', '%TEMP_ZIP%')"

:: === Extract sky textures folder ===
echo Extracting sky textures...
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TEMP_DIR%' -Force"

:: === Copy only the 'sky' folder to each eligible folder ===
for /d %%F in ("%TARGET_ROOT%\*") do (
    set "folder=%%~nxF"
    if /i not "!folder!"=="skyboxfix" if /i not "!folder!"=="Change settings Or change textures" (
        echo Replacing 'sky' folder in %%F...
        if exist "%%F\sky" rd /s /q "%%F\sky"
        xcopy /E /I /Y "%EXTRACTED_SKY%\sky" "%%F\sky\"
    ) else (
        echo Skipping %%F
    )
)

:: === Cleanup ===
del "%TEMP_ZIP%"
rd /s /q "%TEMP_DIR%"

echo Done.
pause
