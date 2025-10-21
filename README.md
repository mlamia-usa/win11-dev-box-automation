# Windows 11 Workstation Automation

A PowerShell DSC-based configuration management system for automating Windows 11 workstation setup and configuration.

## Overview

This project provides a bootstrap script that downloads configuration files from GitHub and applies them to a Windows 11 workstation using PowerShell Desired State Configuration (DSC). The system is designed to be executed from a browser download, making it easy to bootstrap new workstations.

## Prerequisites

- Windows 11 workstation
- PowerShell 5.1 or later
- Internet connectivity
- Administrative privileges

## Quick Start (Phase 1 Testing)

### 1. Download and Execute Bootstrap Script

```powershell
# Download the bootstrap script from GitHub
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_USERNAME/win11-dev-box-automation/main/src/Bootstrap-Workstation.ps1" -OutFile "C:\Temp\Bootstrap-Workstation.ps1"

# Execute the bootstrap script
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
& "C:\Temp\Bootstrap-Workstation.ps1"
```

### 2. Verify Configuration Applied

After execution, verify the computer name has been changed:

```powershell
# Check current computer name
$env:COMPUTERNAME

# Check if DSC configuration was applied
Get-DscConfigurationStatus
```

### 3. Expected Results

- Computer name should be set to "LAB-WIN11-01"
- Configuration files downloaded to `C:\Temp\WorkstationConfig\`
- Bootstrap log created at `C:\Windows\Temp\Bootstrap-[timestamp].log`

## Project Structure

```
win11-dev-box-automation/
├── .gitignore
├── README.md
├── docs/
│   └── specs/
│       └── project-spec.md
├── src/
│   ├── Bootstrap-Workstation.ps1
│   └── WorkstationConfiguration.ps1
└── configs/
    └── WorkstationData.psd1
```

## Testing Locally

1. Clone this repository to your local machine
2. Navigate to the project directory
3. Execute the bootstrap script locally:

```powershell
# Run bootstrap script locally
& ".\src\Bootstrap-Workstation.ps1"
```

## GitHub URL Pattern

When this repository is pushed to GitHub, the bootstrap script can be downloaded using:

```
https://raw.githubusercontent.com/YOUR_USERNAME/win11-dev-box-automation/main/src/Bootstrap-Workstation.ps1
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Documentation

For detailed project specifications and future phases, see [docs/specs/project-spec.md](docs/specs/project-spec.md).

## Phase 1 Features

- ✅ Bootstrap script with GitHub download capability
- ✅ Basic DSC configuration for computer name
- ✅ Error handling and logging
- ✅ Local testing support

## Future Phases

- Phase 2: Additional workstation settings (users, groups, software)
- Phase 3: Advanced DSC configurations
- Phase 4: Multi-environment support

## Troubleshooting

### Common Issues

1. **Execution Policy Error**: Run `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force`
2. **Network Connectivity**: Ensure internet access for GitHub downloads
3. **Administrative Privileges**: Run PowerShell as Administrator
4. **DSC Module Missing**: Install DSC modules if not present

### Logs

Check the bootstrap log for detailed execution information:
- Location: `C:\Windows\Temp\Bootstrap-[timestamp].log`
- Contains: Download status, configuration application, errors

## Contributing

This is a Phase 1 implementation focused on basic computer name configuration. Future phases will expand functionality based on the project specification.

