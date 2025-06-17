@echo off
setlocal enabledelayedexpansion

:: === Define URLs and paths ===
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "TEMP_ZIP=%TEMP%\white_textures.zip"
set "TEMP_DIR=%TEMP%\white_textures"
set "EXTRACTED_WHITE=%TEMP_DIR%\DebloatedBloxLauncher-main\roblox\Default textures"
set "TARGET_ROOT=%LOCALAPPDATA%\DBL"

:: === Download white textures zip ===
echo Downloading white textures...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ZIP_URL%', '%TEMP_ZIP%')"

:: === Extract white textures folder ===
echo Extracting white textures...
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TEMP_DIR%' -Force"

:: === Copy contents of white textures to each eligible folder, skipping 'sky' folder ===
for /d %%F in ("%TARGET_ROOT%\*") do (
    set "folder=%%~nxF"
    if /i not "!folder!"=="skyboxfix" if /i not "!folder!"=="Change settings Or change textures" (
        echo Deleting contents of %%F except for 'sky' folder...
        rem Delete all subfolders except 'sky'
        for /d %%D in ("%%F\*") do (
            if /i not "%%~nxD"=="sky" (
                rd /s /q "%%D"
            )
        )
        rem Delete all files in the folder
        for %%A in ("%%F\*.*") do (
            del /q "%%A"
        )

        echo Copying white textures contents to %%F, skipping 'sky' folder...
        for /d %%S in ("%EXTRACTED_WHITE%\*") do (
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
        for %%A in ("%EXTRACTED_WHITE%\*") do (
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
