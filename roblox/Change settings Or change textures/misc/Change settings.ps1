# Change settings.ps1

$robloxSettings = Join-Path $env:USERPROFILE 'Documents\roblox\GlobalBasicSettings_13.xml'

if (-not (Test-Path $robloxSettings)) {
    Write-Host "ERROR: Settings file not found at $robloxSettings"
    Write-Host "Make sure Roblox has generated the file before running this script."
    Read-Host "Press Enter to exit"
    exit
}

function Ask-YesNo($prompt) {
    while ($true) {
        $ans = Read-Host "$prompt (yes/no)"
        if ($ans -match '^(y|yes)$') { return $true }
        if ($ans -match '^(n|no)$') { return $false }
        Write-Host "Please enter yes or no."
    }
}

# Prompt user for modifications
$changeSensitivity = Ask-YesNo "Would you like to change sensitivity?"
$changeFPSCap     = Ask-YesNo "Would you like to change FPS cap?"
$changeGraphics   = Ask-YesNo "Would you like to change graphics quality?"
$changeVolume     = Ask-YesNo "Would you like to change Roblox volume?"
Write-Host

# Load XML
[xml]$xml = Get-Content $robloxSettings

# Sensitivity
if ($changeSensitivity) {
    while ($true) {
        $sensitivityInput = Read-Host "Enter Mouse Sensitivity (0.00001 - 100)"
        $sensitivity = $null
        if ([double]::TryParse($sensitivityInput, [ref]$sensitivity) -and $sensitivity -ge 0.00001 -and $sensitivity -le 100) {
            $xml.SelectSingleNode("//float[@name='MouseSensitivity']").InnerText = "$sensitivity"
            $xml.SelectSingleNode("//Vector2[@name='MouseSensitivityFirstPerson']/X").InnerText = "$sensitivity"
            $xml.SelectSingleNode("//Vector2[@name='MouseSensitivityFirstPerson']/Y").InnerText = "$sensitivity"
            $xml.SelectSingleNode("//Vector2[@name='MouseSensitivityThirdPerson']/X").InnerText = "$sensitivity"
            $xml.SelectSingleNode("//Vector2[@name='MouseSensitivityThirdPerson']/Y").InnerText = "$sensitivity"
            Write-Host "Sensitivity set to: $sensitivity"
            break
        } else {
            Write-Host "Invalid input. Sensitivity not changed."
        }
    }
    Write-Host
}

# FPS Cap
if ($changeFPSCap) {
    while ($true) {
        $fpscapInput = Read-Host "Enter FPS cap (1 - 99999 or 'inf' for no cap)"
        if ($fpscapInput -match '^(inf|INF)$') {
            $fpscap = 9999999
            $xml.SelectSingleNode("//int[@name='FramerateCap']").InnerText = "$fpscap"
            Write-Host "FPS cap set to: $fpscap"
            break
        } else {
            $fpscap = $null
            if ([int]::TryParse($fpscapInput, [ref]$fpscap) -and $fpscap -ge 1 -and $fpscap -le 99999) {
                $xml.SelectSingleNode("//int[@name='FramerateCap']").InnerText = "$fpscap"
                Write-Host "FPS cap set to: $fpscap"
                break
            } else {
                Write-Host "Invalid input. FPS cap not changed."
            }
        }
    }
    Write-Host
}

# Graphics Quality
if ($changeGraphics) {
    while ($true) {
        $graphics = Read-Host "Enter Graphics Quality (1 - 20)"
        if ($graphics -match '^(1[0-9]|20|[1-9])$') {
            $xml.SelectSingleNode("//int[@name='GraphicsQualityLevel']").InnerText = "$graphics"
            $xml.SelectSingleNode("//token[@name='SavedQualityLevel']").InnerText = "$graphics"
            Write-Host "Graphics quality set to: $graphics"
            break
        } else {
            Write-Host "Invalid input. Graphics quality must be between 1-20."
        }
    }
    Write-Host
}

# Volume
if ($changeVolume) {
    while ($true) {
        $volume = Read-Host "Enter Volume (1 - 10)"
        if ($volume -match '^(10|[1-9])$') {
            $scaledVolume = [math]::Round([double]$volume / 10, 1)
            $xml.SelectSingleNode("//float[@name='MasterVolume']").InnerText = "$scaledVolume"
            Write-Host "Volume set to: $volume"
            break
        } else {
            Write-Host "Invalid input. Volume must be between 1-10."
        }
    }
    Write-Host
}

# Save XML
$xml.Save($robloxSettings)
Write-Host "Settings updated successfully!"
Read-Host "Press Enter to exit"