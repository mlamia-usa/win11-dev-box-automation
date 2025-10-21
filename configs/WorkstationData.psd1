# Windows 11 Workstation Configuration Data
# This file contains the configuration data for the workstation automation system.
# Phase 1: Basic computer name configuration only
# Future phases will include additional settings

@{
    # Basic workstation identification
    ComputerName = "LAB-WIN11-01"
    
    # TODO: Phase 2 - User account management
    # Users = @(
    #     @{
    #         Name = "LabUser"
    #         Password = "SecurePassword123!"
    #         Description = "Lab workstation user"
    #         Groups = @("Users", "Remote Desktop Users")
    #     }
    # )
    
    # TODO: Phase 2 - Group membership configuration
    # Groups = @(
    #     @{
    #         Name = "LabUsers"
    #         Description = "Lab workstation users"
    #         Members = @("LabUser")
    #     }
    # )
    
    # TODO: Phase 2 - Software installation
    # Software = @(
    #     @{
    #         Name = "Visual Studio Code"
    #         InstallerPath = "C:\Temp\Software\VSCodeSetup.exe"
    #         Arguments = "/SILENT"
    #     },
    #     @{
    #         Name = "Git for Windows"
    #         InstallerPath = "C:\Temp\Software\GitSetup.exe"
    #         Arguments = "/SILENT"
    #     }
    # )
    
    # TODO: Phase 2 - Service configuration
    # Services = @(
    #     @{
    #         Name = "Spooler"
    #         StartupType = "Automatic"
    #         State = "Running"
    #     }
    # )
    
    # TODO: Phase 2 - Registry settings
    # Registry = @(
    #     @{
    #         Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    #         Name = "EnableLUA"
    #         Value = 0
    #         Type = "DWord"
    #     }
    # )
    
    # TODO: Phase 2 - Network configuration
    # Network = @{
    #     Adapters = @(
    #         @{
    #             Name = "Ethernet"
    #             IPAddress = "192.168.1.100"
    #             SubnetMask = "255.255.255.0"
    #             Gateway = "192.168.1.1"
    #             DNS = @("8.8.8.8", "8.8.4.4")
    #         }
    #     )
    # }
    
    # TODO: Phase 2 - Windows features
    # WindowsFeatures = @(
    #     "Hyper-V",
    #     "Containers",
    #     "Microsoft-Windows-Subsystem-Linux"
    # )
    
    # TODO: Phase 2 - Environment variables
    # EnvironmentVariables = @(
    #     @{
    #         Name = "LAB_ENVIRONMENT"
    #         Value = "Development"
    #         Target = "Machine"
    #     }
    # )
    
    # TODO: Phase 2 - File system configuration
    # FileSystem = @(
    #     @{
    #         Path = "C:\LabData"
    #         Type = "Directory"
    #         Permissions = @{
    #             Identity = "LabUser"
    #             Rights = "FullControl"
    #         }
    #     }
    # )
    
    # TODO: Phase 3 - Advanced configurations
    # Advanced = @{
    #     PowerShellExecutionPolicy = "RemoteSigned"
    #     WindowsUpdate = @{
    #         AutomaticUpdates = $true
    #         UpdateLevel = "Recommended"
    #     }
    #     Security = @{
    #         FirewallEnabled = $true
    #         WindowsDefender = $true
    #     }
    # }
}

