## Post Installation PowerShell Script ##
<# Properly configures and hardens a Windows Server 2016 Installation
Based on commands found in MCSA Guide to Installation, Storage,
and Compute with Windows Server 2016 - Greg Tomsho
#>
## Author: W.Bansbach ##
## Order of Operations ##
# 1. Set Date
########## 2. Setup Time Server
# 3. Set Timezone
# 4. Set Static / DHCP IP
# 5. Set DNS Server(s)
# 6. Change System Name
# 7. Join Workgroup or Domain
# 8. Setup Remote Management
# 9. Check for / Install Updates
# 10. Dump Unneccessary Services
# 11. Disable Unneeded Firewall Rules
# 12. Update Windows Defender | Scan System


function Approve-Input {
    <#  Simple Selection Function
       Takes three string parameters
        P1 - Describes what the selection is for
        P2 - Selection 1
        P3 - Selection 2 #>
        
        param ($P0, $P1, $P2)
        $message = 'Make a selection ' + $P1 + ' / ' + $P2
        Write-Host $P0
        while (1) {
            switch (Read-Host -Prompt $message) {
                $P1 { Return 1 }
                $P2 { Return 0 }
            }
            Write-Host 'That was not a valid selection.'
        }
    }


## TWEAK EACH ARRAY AS NEEDED ## 
## Set of services that will be disabled | Windows 10 ##
$wtservices = 'AllJoyn Router Service', 'BranchCache', 'Connected Devices Platform Service', 
            'Connected User Experiences and Telemetry', 'Distributed Link Tracking Client',
            'Downloaded Maps Manager', 'Geolocation Service', 'IP Helper', 
            'Network Connected Devices Auto-Setup', 'Offline Files Payments and NFC/SE Manager',
            'Phone Service', 'Portable Device Enumerator Service', 'Print Spooler',
            'Retail Demo Service', 'Secondary Logon', 'Sensor Service', 'Smart Card',
            'SSDP Discovery', 'TCP/IP NetBIOS Helper', 'Touch Keyboard and Handwriting Panel Service',
            'UPnP Device Host', 'Smart Card Device Enumeration Service', 'Radio Management Service',
            'User Data Access', 'WalletService', 'Windows Camera Frame Server', 'Windows Mobile Hotspot Service',
            'Xbox Live Auth Manager', 'Xbox Live Game Save'

## Set of services that will be disabled | Windows Server ##
$wsservices = 'ActiveX Installer', 'AllJoyn Router Service', 'Bluetooth Support Service', 'CDPUserSvc',
            'Connected Devices Platform Service', 'Connected User Experiences and Telemetry',
            'Contact Data', 'Distributed Link Tracking Client', 'Downloaded Maps Manager',
            'Geolocation Service', 'IP Helper', 'Phone Service', 'Portable Device Enumerator Service',
            'Print Spooler', 'Printer Extensions and Notifications', 'Program Compatibility Assistant Service',
            'Radio Management Service', 'Secondary Logon', 'Sensor Service', 'Sensor Monitoring Service',
            'Sensor Data Service', 'Smart Card', 'Smart Card Enumeration Service', 'Smart Card Removal Policy',
            'SSDP Discovery', 'Still Image Aquisition Events', 'TCP/IP NetBIOS Helper', 
            'Touch Keyboard and Handwriting Panel Service', 'UPnP Device Host', 'User Data Access',
            'User Data Storage', 'WalletService', 'Windows Camera Frame Server', 'Windows Mobile Hotspot Service',
            'Xbox Live Auth Manager', 'Xbox Live Game Save'

## Set of Display Groups to Disable in Windows Firewall
$dgrules = 'Xbox Game UI', 'Cortana', 'Cast to Device functionality', 'DIAL protocol server',
            'DiagTrack', 'AllJoyn Router'

$isdomain = $false

Write-Host '********************** Post Installation Script **********************'

## Set Time & Date
Write-Host "`n`n************************** Set Time & Date ***************************`n`n"
$time = Read-Host -Prompt 'Current Time (3:30): '
If (Approve-Input 'AM or PM?' 'am' 'pm') {
    $period = 'AM'
}
$period = 'PM'

$date = Read-Host -Prompt 'Current Date: '
$datetime = $date + " " + $time + $period

Set-Date -date $datetime


# ## Set Time Server
# Write-Host 'http://support.ntp.org/bin/view/Servers/StratumOneTimeServers'
# $tserver = Read-Host -Prompt 'Time Server: '
# w32tm.exe /config /manualpeerlist:$tserver /syncfromflags:manual /reliable:yes /update
# Start-Service W32Time
# w32tm.exe /query /status

 
## Set Timezone
Write-Host "`n`n**************************** Set Timezone ****************************`n`n"
## Switch commenting on the two commands below to display every timezone
# Get-TimeZone -ListAvailable | Format-List -Property DisplayName, StandardName
Get-TimeZone -Name 'US*', 'pac*', 'cent*' | Format-List -Property DisplayName, StandardName
$tzone = Read-Host -Prompt 'Please find your timezone above (Use the Standard Name): '
Set-TimeZone $tzone


## Set IP
Write-Host "`n`n*************************** Set IP ****************************`n`n"
$dhcp = Approve-Input 'DHCP? (y/n): ' 'y' 'n'
If (-Not $dhcp) {
    $ip = Read-Host -Prompt 'IP: '
    $subnet = Read-Host -Prompt 'Subnet Prefix (ex. 24): '
    $dgate = Read-Host -Prompt 'Default Gateway: '
    $iname = Read-Host -Prompt 'Interface Name: '
    New-NetIPAddress $ip -PrefixLength $subnet -DefaultGateway $dgate -InterfaceAlias $iname
}



## Configure Preferred DNS Server
Write-Host "`n`n************************* Set DNS Server(s) **************************`n`n"
$dns0 = Read-Host -Prompt 'DNS Server 1: '
$dns1 = Read-Host -Prompt 'DNS Server 2: '
Set-DnsClientServerAddress -AsJob -ServerAddresses ($dns0, $dns1) -InterfaceAlias $iname


## Change System Name
Write-Host "`n`n************************** Set System Name ***************************`n`n"
$cname = Read-Host -Prompt 'Computer Name: '
netdom renamecomputer $env:COMPUTERNAME /newname:$cname


## Join Domain or Workgroup
Write-Host "`n`n********************** Set a Domain / Workgroup **********************`n`n"
If (Approve-Input 'Join a Domain or Workgroup?' 'd' 'w') {
    $isdomain = $true
    $dname = Read-Host -Prompt 'Domain Name: '
    Add-Computer -DomainName $dname
}
Else {
    $wname = Read-Host -Prompt 'Workgroup Name: '
    Add-Computer -WorkgroupName $wname
}

## Setup Remote Management
Write-Host "`n`n******************* Configuring Remote Management ********************`n`n"
Invoke-Expression -Command 'cmd.exe /C c:\windows\system32\winrm quickconfig'

Enable-PSRemoting
Test-WSMan -ComputerName $env:COMPUTERNAME

## Check for and Display Current Update Set
Write-Host "`n`n************************ Installing Updates **************************`n`n"
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate -Force
Get-WindowsUpdate | Format-List -Property Size,Status,Title,Description,RebootRequired

If (Approve-Input 'Install Updates?' 'y' 'n') {
    Install-WindowsUpdate
}

## Check for the Current OS
Write-Host "`n`n************************* Removing Services **************************`n`n"

Set-Location $PSScriptRoot
$os = Get-CimInstance Win32_OperatingSystem | Select-Object Caption
If ($os -match 'Server') {
    ## Windows Server
    # Dump Unneccessary Services
    For ($i = 0; $i -le $wsservices.Count; $i++) {
        If ($null -ne $wsservices[$i]) { 
            Set-Service $wsservices[$i] -StartupType Disabled -ErrorAction SilentlyContinue
            $status = 'Disabling - ' + $wsservices[$i]
            Write-Host $status
        }
    }
 
    # Configure Local GPO
    If ( $isdomain ) { ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -WSMember -Force }
    Else { ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -WSNonDomainJoined -Force }
} 
Elseif ($os -match '10') {
    # Windows 10
    ## Dump Unneccessary Services
    For ($i = 0; $i -le $wtservices.Count; $i++) {
        If ($null -ne $wtservices[$i]) { 
            Set-Service $wtservices[$i] -StartupType Disabled -ErrorAction SilentlyContinue
            $status = 'Disabling - ' + $wstervices[$i]
            Write-Host $status
        }
    }

    # Configure Local GPO
    If ( $isdomain ) { ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -Win10DomainJoined -Force }
    Else { ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -Win10NonDomainJoined -Force }
} 


## Manage Firewall
## Display Enabled Firewall Rules
Get-NetFirewallRule -Enabled True | Format-List -Property DisplayName,Direction,Action


Write-Host "`n`n***************** Disabling Unneccessary Firewall Rules *******************`n`n"
## Disable Unneccessary Firewall Rules
For ($i = 0; $i -le $dgrules.Count; $i++) {
    If ($null -ne $dgrules[$i]) { 
        Disable-NetFirewallRule -AsJob -DisplayGroup $dgrules[$i] | Wait-Job
        $status = "Disabling - " + $dgrules[$i] 
        Write-Host $status
     }
}

## Manage Windows Defender
Write-Host "`n`n*********************** Windows Defender Info ************************`n"
Write-Host "*********************** AV Current Status ************************"

Get-MpComputerStatus | Format-List -Property AntispywareEnabled,AntispywareSignatureLastUpdated, `
                            AntivirusEnabled,AntivirusSignatureLastUpdated,BehaviorMonitorEnabled
Write-Host '**********************************************************************'

Set-MpPreference -AsJob -CheckForSignaturesBeforeRunningScan $true -Force `
 -HighThreatDefaultAction Remove -LowThreatDefaultAction Remove `
 -MAPSReporting 0 -QuarantinePurgeItemsAfterDelay 1 -ScanParameters FullScan `
 -ScanScheduleDay Everyday -SevereThreatDefaultAction Remove
Write-Host "`n`n*********************** Current AV Preferences ************************`n"
Get-MpPreference
Write-Host '**********************************************************************'

Update-MpSignature -AsJob | Wait-Job

Start-MpScan
Get-MpThreatDetection
Remove-MpThreat

Write-Host "Restarting Local Host in 10 seconds....."
Start-Sleep -s 10

Restart-Computer localhost
