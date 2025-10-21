<#
.SYNOPSIS
    Bootstrap script for Windows 11 workstation automation.

.DESCRIPTION
    This script downloads configuration files from GitHub and applies them to the workstation
    using PowerShell Desired State Configuration (DSC). It's designed to be executed from
    a browser download, making it easy to bootstrap new workstations.

.PARAMETER GitHubRepo
    The GitHub repository URL (default: https://raw.githubusercontent.com/YOUR_USERNAME/win11-dev-box-automation/main)

.PARAMETER ConfigPath
    Local path to save configuration files (default: C:\Temp\WorkstationConfig)

.EXAMPLE
    .\Bootstrap-Workstation.ps1
    Downloads and applies configuration from the default GitHub repository.

.EXAMPLE
    .\Bootstrap-Workstation.ps1 -GitHubRepo "https://raw.githubusercontent.com/MyOrg/win11-config/main"
    Downloads and applies configuration from a custom GitHub repository.

.NOTES
    Author: Windows 11 Workstation Automation
    Version: 1.0
    Phase: 1 - Basic computer name configuration only
#>

[CmdletBinding()]
param(
    [string]$GitHubRepo = "https://raw.githubusercontent.com/YOUR_USERNAME/win11-dev-box-automation/main",
    [string]$ConfigPath = "C:\Temp\WorkstationConfig"
)

# Set up logging
$LogFile = "C:\Windows\Temp\Bootstrap-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$ErrorActionPreference = "Stop"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

function Test-Prerequisites {
    <#
    .SYNOPSIS
        Tests system prerequisites for the bootstrap process.
    #>
    Write-Log "Testing prerequisites..."
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.1 or later is required. Current version: $($PSVersionTable.PSVersion)"
    }
    Write-Log "PowerShell version check passed: $($PSVersionTable.PSVersion)"
    
    # Check if running as administrator
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as Administrator"
    }
    Write-Log "Administrator privileges confirmed"
    
    # Check internet connectivity
    try {
        $TestConnection = Test-NetConnection -ComputerName "github.com" -Port 443 -InformationLevel Quiet
        if (-not $TestConnection) {
            throw "Cannot connect to GitHub. Please check internet connectivity."
        }
        Write-Log "Internet connectivity confirmed"
    }
    catch {
        throw "Internet connectivity test failed: $($_.Exception.Message)"
    }
}

function Initialize-ConfigDirectory {
    <#
    .SYNOPSIS
        Creates the configuration directory and ensures it's accessible.
    #>
    Write-Log "Initializing configuration directory: $ConfigPath"
    
    try {
        if (-not (Test-Path $ConfigPath)) {
            New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null
            Write-Log "Created configuration directory: $ConfigPath"
        }
        else {
            Write-Log "Configuration directory already exists: $ConfigPath"
        }
        
        # Test write access
        $TestFile = Join-Path $ConfigPath "test.txt"
        "test" | Out-File -FilePath $TestFile -Force
        Remove-Item $TestFile -Force
        Write-Log "Configuration directory write access confirmed"
    }
    catch {
        throw "Failed to initialize configuration directory: $($_.Exception.Message)"
    }
}

function Get-ConfigurationFiles {
    <#
    .SYNOPSIS
        Downloads configuration files from GitHub repository.
    #>
    Write-Log "Downloading configuration files from GitHub..."
    
    $FilesToDownload = @(
        @{
            Name = "WorkstationData.psd1"
            Path = "configs/WorkstationData.psd1"
        },
        @{
            Name = "WorkstationConfiguration.ps1"
            Path = "src/WorkstationConfiguration.ps1"
        }
    )
    
    foreach ($File in $FilesToDownload) {
        try {
            $SourceUrl = "$GitHubRepo/$($File.Path)"
            $DestinationPath = Join-Path $ConfigPath $File.Name
            
            Write-Log "Downloading $($File.Name) from $SourceUrl"
            Invoke-WebRequest -Uri $SourceUrl -OutFile $DestinationPath -UseBasicParsing
            Write-Log "Successfully downloaded $($File.Name)"
            
            # Verify file was downloaded and has content
            if (-not (Test-Path $DestinationPath)) {
                throw "File was not downloaded: $DestinationPath"
            }
            
            $FileSize = (Get-Item $DestinationPath).Length
            if ($FileSize -eq 0) {
                throw "Downloaded file is empty: $DestinationPath"
            }
            
            Write-Log "File verification passed: $($File.Name) ($FileSize bytes)"
        }
        catch {
            throw "Failed to download $($File.Name): $($_.Exception.Message)"
        }
    }
}

function Invoke-WorkstationConfiguration {
    <#
    .SYNOPSIS
        Executes the workstation configuration script.
    #>
    Write-Log "Executing workstation configuration..."
    
    try {
        $ConfigScriptPath = Join-Path $ConfigPath "WorkstationConfiguration.ps1"
        
        if (-not (Test-Path $ConfigScriptPath)) {
            throw "Configuration script not found: $ConfigScriptPath"
        }
        
        Write-Log "Running configuration script: $ConfigScriptPath"
        
        # Change to the configuration directory to ensure relative paths work
        $OriginalLocation = Get-Location
        Set-Location $ConfigPath
        
        try {
            # Execute the configuration script
            & $ConfigScriptPath
            Write-Log "Configuration script executed successfully"
        }
        finally {
            # Restore original location
            Set-Location $OriginalLocation
        }
    }
    catch {
        throw "Failed to execute workstation configuration: $($_.Exception.Message)"
    }
}

function Show-Summary {
    <#
    .SYNOPSIS
        Displays a summary of the bootstrap process.
    #>
    Write-Log "Bootstrap process completed successfully!"
    Write-Log "Configuration files saved to: $ConfigPath"
    Write-Log "Bootstrap log saved to: $LogFile"
    Write-Log "Current computer name: $env:COMPUTERNAME"
    
    # Check if DSC configuration was applied
    try {
        $DscStatus = Get-DscConfigurationStatus -ErrorAction SilentlyContinue
        if ($DscStatus) {
            Write-Log "DSC configuration status: $($DscStatus.Status)"
        }
    }
    catch {
        Write-Log "Could not retrieve DSC configuration status"
    }
}

# Main execution
try {
    Write-Log "Starting Windows 11 Workstation Bootstrap Process"
    Write-Log "GitHub Repository: $GitHubRepo"
    Write-Log "Configuration Path: $ConfigPath"
    Write-Log "Log File: $LogFile"
    
    # Execute bootstrap steps
    Test-Prerequisites
    Initialize-ConfigDirectory
    Get-ConfigurationFiles
    Invoke-WorkstationConfiguration
    Show-Summary
    
    Write-Log "Bootstrap process completed successfully!"
    Write-Host "`nBootstrap completed successfully! Check the log file for details: $LogFile" -ForegroundColor Green
}
catch {
    $ErrorMessage = "Bootstrap process failed: $($_.Exception.Message)"
    Write-Log $ErrorMessage "ERROR"
    Write-Host "`n$ErrorMessage" -ForegroundColor Red
    Write-Host "Check the log file for details: $LogFile" -ForegroundColor Yellow
    exit 1
}

