# ============================================
# Windows Enterprise Hardening & Debloat Script
# Created by Priyant.in
# Provider-safe (uses .NET registry)
# ============================================

# Enforce Admin
If (-NOT ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Run this script as Administrator." -ForegroundColor Red
    Exit 1
}

Write-Host "Executing System Configuration Script - Created by Priyant.in" -ForegroundColor Cyan

# ==============================
# Helper: Set Registry (Safe)
# ==============================
function Set-RegDWORD {
    param (
        [string]$Hive,
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    switch ($Hive) {
        "HKLM" { $base = [Microsoft.Win32.Registry]::LocalMachine }
        "HKCU" { $base = [Microsoft.Win32.Registry]::CurrentUser }
        "HKU"  { $base = [Microsoft.Win32.Registry]::Users }
    }

    $key = $base.CreateSubKey($Path)
    $key.SetValue($Name, $Value, [Microsoft.Win32.RegistryValueKind]::DWord)
    $key.Close()
}

# ==============================
# Disable Telemetry & Tracking
# ==============================
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" 1

# ==============================
# Disable Ads, Tips, Consumer Features
# ==============================
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightFeatures" 1
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableSoftLanding" 1
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableTailoredExperiencesWithDiagnosticData" 1

# ==============================
# Disable Copilot / AI
# ==============================
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 1

# ==============================
# Disable Bing Search
# ==============================
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb" 0
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Windows\Windows Search" "EnableDynamicContentInWSB" 0

# ==============================
# Disable Widgets / News
# ==============================
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" 0

# ==============================
# Disable Fast Startup
# ==============================
Set-RegDWORD "HKLM" "SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" 0

# ==============================
# Default User Profile (New Users)
# ==============================
Set-RegDWORD "HKU" ".DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
Set-RegDWORD "HKU" ".DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0

# ==============================
# Explorer Cleanup
# ==============================
Set-RegDWORD "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "HubMode" 1

# ==============================
# Edge Policies
# ==============================
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Edge" "HideFirstRunExperience" 1
Set-RegDWORD "HKLM" "SOFTWARE\Policies\Microsoft\Edge" "NewTabPageContentEnabled" 0

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
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "Configuration Applied Successfully." -ForegroundColor Green
