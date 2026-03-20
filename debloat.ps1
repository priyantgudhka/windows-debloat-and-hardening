# ============================================
# Windows Enterprise Hardening & Debloat Script
# Created by Priyant.in
# ============================================

# Enforce Admin Execution
If (-NOT ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Run this script as Administrator." -ForegroundColor Red
    Exit 1
}

Write-Host "Executing System Configuration Script - Created by Priyant.in" -ForegroundColor Cyan

# ==============================
# Helper: Ensure Registry Path
# ==============================
function Ensure-RegPath {
    param ([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

# ==============================
# Disable Telemetry & Data Collection
# ==============================
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "AllowTelemetry" -Type DWord -Value 0

$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "DisabledByGroupPolicy" -Type DWord -Value 1

$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "DisableWindowsSpotlightFeatures" -Type DWord -Value 1

# ==============================
# Disable Tips, Suggestions, Ads
# ==============================
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "DisableSoftLanding" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

# ==============================
# Disable Copilot, AI, Recall
# ==============================
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "TurnOffWindowsCopilot" -Type DWord -Value 1

$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "DisableAIDataAnalysis" -Type DWord -Value 1

# ==============================
# Disable Bing + Web Search
# ==============================
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "DisableWebSearch" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "ConnectedSearchUseWeb" -Type DWord -Value 0

# ==============================
# Taskbar / UX Cleanup (System Policies)
# ==============================
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "AllowNewsAndInterests" -Type DWord -Value 0

$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "EnableDynamicContentInWSB" -Type DWord -Value 0

# ==============================
# Disable Fast Startup
# ==============================
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" `
-Name "HiberbootEnabled" -Type DWord -Value 0

# ==============================
# Default User Profile (applies to new users)
# ==============================
$defaultUser = "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Ensure-RegPath $defaultUser
Set-ItemProperty -Path $defaultUser -Name "HideFileExt" -Type DWord -Value 0
Set-ItemProperty -Path $defaultUser -Name "ShowTaskViewButton" -Type DWord -Value 0

# ==============================
# Explorer Cleanup
# ==============================
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "HubMode" -Type DWord -Value 1

# ==============================
# Microsoft Edge Policies
# ==============================
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
Ensure-RegPath $path
Set-ItemProperty -Path $path -Name "HideFirstRunExperience" -Type DWord -Value 1
Set-ItemProperty -Path $path -Name "NewTabPageContentEnabled" -Type DWord -Value 0

# ==============================
# Remove Preinstalled Apps (All Users + Provisioned)
# ==============================
$apps = @(
    "*Spotify*",
    "*LinkedIn*",
    "*Facebook*",
    "*Instagram*",
    "*Xbox*",
    "*GamingApp*",
    "*ZuneMusic*",
    "*ZuneVideo*",
    "*BingNews*",
    "*MicrosoftSolitaireCollection*",
    "*GetHelp*",
    "*GetStarted*"
)

foreach ($app in $apps) {
    Get-AppxPackage -AllUsers -Name $app | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
    }

    Get-AppxProvisionedPackage -Online | Where-Object {
        $_.DisplayName -like $app
    } | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    }
}

# ==============================
# Restart Explorer (non-critical)
# ==============================
Try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} Catch {}

Write-Host "Configuration Applied Successfully." -ForegroundColor Green
