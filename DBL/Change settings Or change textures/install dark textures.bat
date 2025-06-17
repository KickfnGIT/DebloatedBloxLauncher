@echo off
setlocal enabledelayedexpansion

:: === Define URLs and paths ===
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "TEMP_ZIP=%TEMP%\dark_textures.zip"
set "TEMP_DIR=%TEMP%\dark_textures"
set "EXTRACTED_DARK=%TEMP_DIR%\DebloatedBloxLauncher-main\dark textures roblox"
set "TARGET_ROOT=%LOCALAPPDATA%\DBL"

:: === Download dark textures zip ===
echo Downloading dark textures...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ZIP_URL%', '%TEMP_ZIP%')"

:: === Extract dark textures folder ===
echo Extracting dark textures...
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TEMP_DIR%' -Force"

:: === Copy contents of dark textures to each eligible folder, skipping 'sky' folder ===
for /d %%F in ("%TARGET_ROOT%\*") do (
    set "folder=%%~nxF"
    if /i not "!folder!"=="skyboxfix" if /i not "!folder!"=="Change settings Or change textures" (
        echo Copying dark textures contents to %%F, skipping 'sky' folder...
        for /d %%S in ("%EXTRACTED_DARK%\*") do (
            set "subfolder=%%~nxS"
            if /i not "!subfolder!"=="sky" (
                xcopy /E /I /Y "%%S" "%%F\!subfolder!\"
            ) else (
                if not exist "%%F\sky" (
                    xcopy /E /I /Y "%%S" "%%F\sky\"
                ) else (
                    echo Skipping 'sky' folder in %%F
                )
            )
        )
        for %%A in ("%EXTRACTED_DARK%\*") do (
            if not exist "%%A\" (
                xcopy /Y "%%A" "%%F\"
            )
        )
    ) else (
        echo Skipping %%F
    )
)

:: === Cleanup ===
del "%TEMP_ZIP%"
rd /s /q "%TEMP_DIR%"

echo Done.
pause
