# ============================================
# Windows Enterprise Hardening & Debloat Script
# Created by Priyant.in
# Compatible with PowerShell 5.1+
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
# Helper: Set Registry DWORD
# ==============================
function Set-RegDWORD {
    param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )
    Ensure-RegPath $Path
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
}

# ==============================
# Disable Telemetry & Tracking
# ==============================
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" 1

# ==============================
# Disable Consumer Features, Ads, Tips
# ==============================
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightFeatures" 1
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableSoftLanding" 1
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableTailoredExperiencesWithDiagnosticData" 1

# ==============================
# Disable Copilot, AI, Recall
# ==============================
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 1

# ==============================
# Disable Bing Search & Web Integration
# ==============================
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb" 0
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "EnableDynamicContentInWSB" 0

# ==============================
# Disable Widgets / News
# ==============================
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" 0

# ==============================
# Disable Fast Startup
# ==============================
Set-RegDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" 0

# ==============================
# Default User Profile Settings (New Users)
# ==============================
$defaultUser = "HKU\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-RegDWORD $defaultUser "HideFileExt" 0
Set-RegDWORD $defaultUser "ShowTaskViewButton" 0

# ==============================
# Explorer Cleanup
# ==============================
Set-RegDWORD "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "HubMode" 1

# ==============================
# Microsoft Edge Policies
# ==============================
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "HideFirstRunExperience" 1
Set-RegDWORD "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "NewTabPageContentEnabled" 0

# ==============================
# Remove Preinstalled Apps
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
# Restart Explorer
# ==============================
Try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} Catch {}

Write-Host "Configuration Applied Successfully." -ForegroundColor Green
