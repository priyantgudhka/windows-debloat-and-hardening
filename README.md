# Windows Debloat & Hardening Script

PowerShell-based script to standardize, harden, and clean Windows endpoints at the system level. Built for controlled environments where consistency, reduced attack surface, and removal of unnecessary components are required.

---

## Overview

This script applies system-level configurations using policy-backed registry keys and removes preinstalled applications across all users. It avoids PowerShell provider limitations by using direct registry access methods, ensuring consistent execution across Windows 10/11 with PowerShell 5.1+.

---

## Key Capabilities

- Disables telemetry, tracking, and advertising identifiers  
- Removes Windows tips, suggestions, and consumer experience features  
- Disables Copilot, AI-related components, and web-integrated search  
- Removes widgets, news feed, and taskbar clutter  
- Disables Fast Startup  
- Enforces default user settings (file extensions visible, task view hidden)  
- Configures Microsoft Edge to suppress first-run prompts and content feeds  
- Removes preinstalled applications (Spotify, Xbox, LinkedIn, etc.)  
- Applies settings at system level (HKLM) for all users  

---

## Execution Methods

### 1. One-Line Remote Execution

Run in **Administrator PowerShell**:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/priyantgudhka/windows-debloat-and-hardening/main/debloat.ps1')))"
```
2. Local Execution

Download and execute manually:
```powershell
irm "https://raw.githubusercontent.com/priyantgudhka/windows-debloat-and-hardening/main/debloat.ps1" -OutFile debloat.ps1
powershell -ExecutionPolicy Bypass -File .\debloat.ps1
```
## Requirements

- Administrator privileges
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Internet access (for remote execution)

## Behavior Notes

- Changes are applied using system policies where possible
- Explorer process is restarted automatically
- Some settings require user logoff or system reboot to fully apply
- App removal runs silently; non-critical errors are suppressed

## Testing Protocol

- Execute on a clean virtual machine before production rollout
- Validate:
  - Registry changes under HKLM:\SOFTWARE\Policies\...
  - Removal of targeted applications
  - Taskbar and search behavior changes

## Security Considerations
- Remote execution (irm) runs code directly in memory
- Only execute scripts from controlled and trusted sources
- For enterprise deployment, prefer:
  - Internal hosting (IIS / secure endpoint)
  - Version-controlled script URLs

## Author
### <a href="https://priyant.in" target="_blank">Priyant.in</a>
