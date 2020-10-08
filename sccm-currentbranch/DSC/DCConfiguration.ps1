configuration Configuration
{
   param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,
        [Parameter(Mandatory)]
        [String]$DCName,
        [Parameter(Mandatory)]
        [String]$DPMPName,
        [Parameter(Mandatory)]
        [String]$ClientName,
        [Parameter(Mandatory)]
        [string]$AADCName,
        [Parameter(Mandatory)]
        [string]$AADProxyName,
        [Parameter(Mandatory)]
        [string]$InTuneGWName,
        [Parameter(Mandatory)]
        [string]$TunGWName,
        [Parameter(Mandatory)]
        [string]$WinSvrName,
        [Parameter(Mandatory)]
        [String]$PSName,
        [Parameter(Mandatory)]
        [String]$DNSIPAddress,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds
    )

    Import-DscResource -ModuleName TemplateHelpDSC

    $LogFolder = "TempLog"
    $LogPath = "c:\$LogFolder"
    $CM = "CMCB"
    $DName = $DomainName.Split(".")[0]
    $PSComputerAccount = "$DName\$PSName$"
    $DPMPComputerAccount = "$DName\$DPMPName$"
    $ClientComputerAccount = "$DName\$ClientName$"
    $AADCComputerAccount = "$DName\$AADCName$"
    $AADProxyComputerAccount = "$DName\$AADProxyName$"
    $InTuneGWComputerAccount = "$DName\$InTuneGWName$"
    $TunGWComputerAccount  = "$DName\$TunGWName$"
    $WinSvrComputerAccount = "$DName\$WinSvrName$"

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    Node LOCALHOST
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        SetCustomPagingFile PagingSettings
        {
            Drive       = 'C:'
            InitialSize = '8192'
            MaximumSize = '8192'
        }
        
        InstallFeatureForSCCM InstallFeature
        {
            Name = 'DC'
            Role = 'DC'
            DependsOn = "[SetCustomPagingFile]PagingSettings"
        }

        SetupDomain FirstDS
        {
            DomainFullName = $DomainName
            SafemodeAdministratorPassword = $DomainCreds
            DependsOn = "[InstallFeatureForSCCM]InstallFeature"
        }

        InstallCA InstallCA
        {
            HashAlgorithm = "SHA256"
            DependsOn = "[SetupDomain]FirstDS"
        }

        VerifyComputerJoinDomain WaitForPS
        {
            ComputerName = $PSName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForDPMP
        {
            ComputerName = $DPMPName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForClient
        {
            ComputerName = $ClientName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForAADC
        {
            ComputerName = $AADCName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForAADProxy
        {
            ComputerName = $AADProxyName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForInTuneGW
        {
            ComputerName = $InTuneGWName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForTunGW
        {
            ComputerName = $TunGWName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        VerifyComputerJoinDomain WaitForWinSvr
        {
            ComputerName = $WinSvrName
            Ensure = "Present"
            DependsOn = "[InstallCA]InstallCA"
        }

        File ShareFolder
        {            
            DestinationPath = $LogPath     
            Type = 'Directory'            
            Ensure = 'Present'
            DependsOn = @("[VerifyComputerJoinDomain]WaitForPS","[VerifyComputerJoinDomain]WaitForDPMP","[VerifyComputerJoinDomain]WaitForClient","[VerifyComputerJoinDomain]WaitForAADC","[VerifyComputerJoinDomain]WaitForAADProxy","[VerifyComputerJoinDomain]WaitForInTuneGW","[VerifyComputerJoinDomain]WaitForTunGW","[VerifyComputerJoinDomain]WaitForWinSvr")
        }

        FileReadAccessShare DomainSMBShare
        {
            Name   = $LogFolder
            Path =  $LogPath
            Account = $PSComputerAccount,$DPMPComputerAccount,$ClientComputerAccount,$AADCComputerAccount,$AADProxyComputerAccount,$InTuneGWComputerAccount,$TunGWComputerAccount,$WinSvrComputerAccount
            DependsOn = "[File]ShareFolder"
        }

        WriteConfigurationFile WritePSJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "PSJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteDPMPJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "DPMPJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteClientJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "ClientJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteAADCJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "AADCJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteAADProxyJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "AADProxyJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteInTuneGWJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "InTuneGWJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteTunGWJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "TunGWJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        WriteConfigurationFile WriteWinSvrJoinDomain
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "WinSvrJoinDomain"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = "[FileReadAccessShare]DomainSMBShare"
        }

        DelegateControl AddPS
        {
            Machine = $PSName
            DomainFullName = $DomainName
            Ensure = "Present"
            DependsOn = "[WriteConfigurationFile]WritePSJoinDomain"
        }

        DelegateControl AddDPMP
        {
            Machine = $DPMPName
            DomainFullName = $DomainName
            Ensure = "Present"
            DependsOn = "[WriteConfigurationFile]WriteDPMPJoinDomain"
        }

        WriteConfigurationFile WriteDelegateControlfinished
        {
            Role = "DC"
            LogPath = $LogPath
            WriteNode = "DelegateControl"
            Status = "Passed"
            Ensure = "Present"
            DependsOn = @("[DelegateControl]AddPS","[DelegateControl]AddDPMP")
        }

        WaitForExtendSchemaFile WaitForExtendSchemaFile
        {
            MachineName = $PSName
            ExtFolder = $CM
            Ensure = "Present"
            DependsOn = "[WriteConfigurationFile]WriteDelegateControlfinished"
        }
    }
}