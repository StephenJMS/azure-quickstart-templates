Param($DomainFullName,$CM,$CMUser,$DPMPName,$ClientName,$AADCName,$AADProxyName,$InTuneGWName,$TunGWName,$WinSvrName)

$Role = "PS1"
$ProvisionToolPath = "$env:windir\temp\ProvisionScript"
if(!(Test-Path $ProvisionToolPath))
{
    New-Item $ProvisionToolPath -ItemType directory | Out-Null
}

$ConfigurationFile = Join-Path -Path $ProvisionToolPath -ChildPath "$Role.json"

if (Test-Path -Path $ConfigurationFile) 
{
    $Configuration = Get-Content -Path $ConfigurationFile | ConvertFrom-Json
} 
else 
{
    [hashtable]$Actions = @{
        InstallSCCM = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        UpgradeSCCM = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallDP = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallMP = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallClient = @{
            Status = 'NotStart'
            StartTime = ''
            EndTime = ''
        }
        InstallAADC = @{
            Status = 'NoStart'
            StartTime = ''
            EndTime = ''
        }
        InstallAADProxy = @{
            Status = 'NoStart'
            StartTime = ''
            EndTime = ''
        }
        InstallInTuneGW = @{
            Status = 'NoStart'
            StartTime = ''
            EndTime = ''
        }
        InstallTunGW = @{
            Status = 'NoStart'
            StartTime = ''
            EndTime = ''
        }
        InstallWinSvr = @{
            Status = 'NoStart'
            StartTime = ''
            EndTime = ''
        }
    }
    $Configuration = New-Object -TypeName psobject -Property $Actions
    $Configuration | ConvertTo-Json | Out-File -FilePath $ConfigurationFile -Force
}

#Install CM and Config
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallAndUpdateSCCM.ps1"

. $ScriptFile $DomainFullName $CM $CMUser $Role $ProvisionToolPath

#Install DP
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallDP.ps1"

. $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath

#Install MP
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallMP.ps1"

. $ScriptFile $DomainFullName $DPMPName $Role $ProvisionToolPath

#Install Client
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallClient.ps1"

. $ScriptFile $DomainFullName $CMUser $ClientName $DPMPName $Role $ProvisionToolPath

#Install AADC
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallAADC.ps1"

. $ScriptFile $DomainFullName $CMUser $AADCName $DPMPName $Role $ProvisionToolPath

#Install AADProxy
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallAADProxy.ps1"

. $ScriptFile $DomainFullName $CMUser $AADProxyName $DPMPName $Role $ProvisionToolPath

#Install InTuneGW
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallInTuneGW.ps1"

. $ScriptFile $DomainFullName $CMUser $InTuneGWName $DPMPName $Role $ProvisionToolPath

#Install TunGW
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallTunGW.ps1"

. $ScriptFile $DomainFullName $CMUser $TunGWName $DPMPName $Role $ProvisionToolPath

#Install WinSvr
$ScriptFile = Join-Path -Path $ProvisionToolPath -ChildPath "InstallWinSvr.ps1"

. $ScriptFile $DomainFullName $CMUser $WinSvrName $DPMPName $Role $ProvisionToolPath
