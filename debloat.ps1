# ============================================
# System Hardening & Debloat Script
# Created by Priyant.in
# ============================================

# Ensure script runs as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Run this script as Administrator." -ForegroundColor Red
    Exit
}

Write-Host "Executing System Configuration Script - Created by Priyant.in" -ForegroundColor Cyan

# ==============================
# Disable Telemetry & Tracking
# ==============================
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# Disable Advertising ID
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1 -Type DWord -Force

# Disable Tailored Experiences
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0

# ==============================
# Disable Tips, Suggestions, Ads
# ==============================
$ContentDelivery = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $ContentDelivery -Name "SystemPaneSuggestionsEnabled" -Value 0
Set-ItemProperty -Path $ContentDelivery -Name "SubscribedContent-338388Enabled" -Value 0
Set-ItemProperty -Path $ContentDelivery -Name "SubscribedContent-338389Enabled" -Value 0
Set-ItemProperty -Path $ContentDelivery -Name "SubscribedContent-353694Enabled" -Value 0

# Lock Screen Ads
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightFeatures" -Value 1 -Type DWord -Force

# ==============================
# Disable Copilot, Recall, AI Features
# ==============================
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1

# Disable Recall (future-proof)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Value 1

# ==============================
# Disable Fast Startup
# ==============================
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0

# ==============================
# Show File Extensions
# ==============================
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# ==============================
# Disable Bing Search & Copilot in Search
# ==============================
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0

# ==============================
# Taskbar Cleanup
# ==============================
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

# Disable Widgets
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0

# ==============================
# Disable Search Highlights
# ==============================
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "EnableDynamicContentInWSB" -Value 0

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
    "*GetHelp*",
    "*Getstarted*",
    "*BingNews*",
    "*MicrosoftSolitaireCollection*"
)

foreach ($app in $apps) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# ==============================
# Disable Edge News Feed & Suggestions
# ==============================
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageContentEnabled" -Value 0

# ==============================
# Hide 'Home' in Explorer
# ==============================
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "HubMode" -Value 1

# ==============================
# Restart Explorer to Apply Changes
# ==============================
Stop-Process -Name explorer -Force

Write-Host "Configuration Applied Successfully." -ForegroundColor Green
