<#
.SYNOPSIS
    PowerShell DSC configuration for Windows 11 workstation automation.

.DESCRIPTION
    This script defines a PowerShell Desired State Configuration (DSC) that applies
    workstation settings based on the configuration data in WorkstationData.psd1.
    Phase 1 focuses on basic computer name configuration.

.PARAMETER ConfigurationData
    The configuration data hashtable containing workstation settings.

.EXAMPLE
    .\WorkstationConfiguration.ps1
    Applies the workstation configuration using the default data file.

.NOTES
    Author: Windows 11 Workstation Automation
    Version: 1.0
    Phase: 1 - Basic computer name configuration only
    
    DSC Concepts:
    - Configuration: A PowerShell script that defines the desired state
    - Node: A target machine that will receive the configuration
    - Resource: A DSC resource that manages a specific aspect of the system
    - MOF: Managed Object Format file that contains the compiled configuration
#>

[CmdletBinding()]
param(
    [string]$ConfigurationDataPath = ".\WorkstationData.psd1"
)

# Import required DSC modules
Import-Module -Name PSDesiredStateConfiguration -Force

function Test-ConfigurationData {
    <#
    .SYNOPSIS
        Validates the configuration data file and loads it.
    #>
    param(
        [string]$DataPath
    )
    
    Write-Host "Loading configuration data from: $DataPath" -ForegroundColor Green
    
    if (-not (Test-Path $DataPath)) {
        throw "Configuration data file not found: $DataPath"
    }
    
    try {
        $ConfigData = Import-PowerShellDataFile -Path $DataPath
        Write-Host "Configuration data loaded successfully" -ForegroundColor Green
        
        # Validate required fields
        if (-not $ConfigData.ComputerName) {
            throw "ComputerName is required in configuration data"
        }
        
        Write-Host "Computer name will be set to: $($ConfigData.ComputerName)" -ForegroundColor Yellow
        return $ConfigData
    }
    catch {
        throw "Failed to load configuration data: $($_.Exception.Message)"
    }
}

function New-WorkstationConfiguration {
    <#
    .SYNOPSIS
        Creates the DSC configuration for workstation setup.
        
    .DESCRIPTION
        This function defines a PowerShell DSC configuration that:
        1. Sets the computer name
        2. Ensures the system is in the desired state
        3. Provides clear error handling and logging
        
    .PARAMETER ConfigurationData
        The configuration data hashtable containing workstation settings.
    #>
    param(
        [hashtable]$ConfigurationData
    )
    
    Write-Host "Creating DSC configuration..." -ForegroundColor Green
    
    # Define the DSC configuration
    Configuration WorkstationConfig {
        param(
            [hashtable]$ConfigData
        )
        
        # Import required DSC resources
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        
        # Node configuration - targets the local machine
        Node localhost {
            
            # Computer name configuration
            # This resource ensures the computer name matches the desired value
            Computer ComputerName {
                Name = $ConfigData.ComputerName
                Ensure = "Present"
            }
            
            # TODO: Phase 2 - Additional configurations will be added here
            # Examples of future configurations:
            
            # User account management
            # User LabUser {
            #     UserName = "LabUser"
            #     Password = $ConfigData.Users[0].Password
            #     Description = $ConfigData.Users[0].Description
            #     Ensure = "Present"
            # }
            
            # Group membership
            # Group LabUsersGroup {
            #     GroupName = "LabUsers"
            #     Members = $ConfigData.Users[0].Name
            #     Ensure = "Present"
            # }
            
            # Service configuration
            # Service SpoolerService {
            #     Name = "Spooler"
            #     StartupType = "Automatic"
            #     State = "Running"
            #     Ensure = "Present"
            # }
            
            # Registry settings
            # Registry EnableLUA {
            #     Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            #     ValueName = "EnableLUA"
            #     ValueData = 0
            #     ValueType = "DWord"
            #     Ensure = "Present"
            # }
        }
    }
    
    Write-Host "DSC configuration defined successfully" -ForegroundColor Green
    return WorkstationConfig
}

function Compile-Configuration {
    <#
    .SYNOPSIS
        Compiles the DSC configuration into a MOF file.
        
    .DESCRIPTION
        This function compiles the DSC configuration into a Managed Object Format (MOF)
        file that can be applied to the target machine. The MOF file contains the
        compiled configuration in a format that DSC can understand and execute.
    #>
    param(
        [scriptblock]$Configuration,
        [hashtable]$ConfigurationData
    )
    
    Write-Host "Compiling DSC configuration..." -ForegroundColor Green
    
    try {
        # Compile the configuration
        # This creates a MOF file in the current directory
        & $Configuration -ConfigurationData $ConfigurationData
        
        # Verify MOF file was created
        $MofFile = "localhost.mof"
        if (-not (Test-Path $MofFile)) {
            throw "MOF file was not created: $MofFile"
        }
        
        Write-Host "Configuration compiled successfully: $MofFile" -ForegroundColor Green
        
        # Display MOF file size
        $MofSize = (Get-Item $MofFile).Length
        Write-Host "MOF file size: $MofSize bytes" -ForegroundColor Yellow
        
        return $MofFile
    }
    catch {
        throw "Failed to compile configuration: $($_.Exception.Message)"
    }
}

function Apply-Configuration {
    <#
    .SYNOPSIS
        Applies the compiled DSC configuration to the local machine.
        
    .DESCRIPTION
        This function applies the compiled MOF file to the local machine using
        the Start-DscConfiguration cmdlet. It includes error handling and
        progress monitoring.
    #>
    param(
        [string]$MofFile
    )
    
    Write-Host "Applying DSC configuration..." -ForegroundColor Green
    
    try {
        # Start the DSC configuration
        # -Path: Specifies the directory containing the MOF file
        # -Force: Forces the configuration to run even if it's already applied
        # -Verbose: Provides detailed output
        # -Wait: Waits for the configuration to complete
        
        Write-Host "Starting DSC configuration application..." -ForegroundColor Yellow
        Start-DscConfiguration -Path (Get-Location) -Force -Verbose -Wait
        
        Write-Host "DSC configuration applied successfully!" -ForegroundColor Green
        
        # Check the configuration status
        $Status = Get-DscConfigurationStatus
        Write-Host "Configuration Status: $($Status.Status)" -ForegroundColor Yellow
        Write-Host "Configuration Mode: $($Status.Mode)" -ForegroundColor Yellow
        
        if ($Status.Status -eq "Success") {
            Write-Host "All resources were configured successfully!" -ForegroundColor Green
        }
        else {
            Write-Warning "Configuration completed with warnings or errors"
        }
    }
    catch {
        throw "Failed to apply configuration: $($_.Exception.Message)"
    }
}

function Show-ConfigurationSummary {
    <#
    .SYNOPSIS
        Displays a summary of the configuration process.
    #>
    param(
        [hashtable]$ConfigurationData
    )
    
    Write-Host "`n=== Configuration Summary ===" -ForegroundColor Cyan
    Write-Host "Computer Name: $($ConfigurationData.ComputerName)" -ForegroundColor White
    Write-Host "Current Computer Name: $env:COMPUTERNAME" -ForegroundColor White
    
    if ($env:COMPUTERNAME -ne $ConfigurationData.ComputerName) {
        Write-Host "`nNOTE: Computer name change requires a restart to take effect." -ForegroundColor Yellow
        Write-Host "Please restart the computer to complete the configuration." -ForegroundColor Yellow
    }
    else {
        Write-Host "`nComputer name is already set correctly." -ForegroundColor Green
    }
    
    Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
    Write-Host "1. Verify the configuration was applied successfully" -ForegroundColor White
    Write-Host "2. Check the DSC configuration status" -ForegroundColor White
    Write-Host "3. Restart the computer if the name was changed" -ForegroundColor White
    Write-Host "4. Verify the new computer name after restart" -ForegroundColor White
}

# Main execution
try {
    Write-Host "`n=== Windows 11 Workstation Configuration ===" -ForegroundColor Cyan
    Write-Host "Phase 1: Basic Computer Name Configuration" -ForegroundColor Yellow
    Write-Host "===============================================`n" -ForegroundColor Cyan
    
    # Load and validate configuration data
    $ConfigData = Test-ConfigurationData -DataPath $ConfigurationDataPath
    
    # Create the DSC configuration
    $Configuration = New-WorkstationConfiguration -ConfigurationData $ConfigData
    
    # Compile the configuration
    $MofFile = Compile-Configuration -Configuration $Configuration -ConfigurationData $ConfigData
    
    # Apply the configuration
    Apply-Configuration -MofFile $MofFile
    
    # Show summary
    Show-ConfigurationSummary -ConfigurationData $ConfigData
    
    Write-Host "`nWorkstation configuration completed successfully!" -ForegroundColor Green
}
catch {
    $ErrorMessage = "Workstation configuration failed: $($_.Exception.Message)"
    Write-Host "`n$ErrorMessage" -ForegroundColor Red
    Write-Host "Please check the error details and try again." -ForegroundColor Yellow
    exit 1
}

