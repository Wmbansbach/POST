## Author: W.Bansbach ##
## Post Installation PowerShell Script ##
<# Properly configures and hardens a Windows Server 2016 Installation
Based on commands found in MCSA Guide to Installation, Storage,
and Compute with Windows Server 2016 - Greg Tomsho
#>
## Order of Operations ##
# 1. OS Check
# 2. Set Timezone
# 3. Change System Name
# 4. Join Workgroup \ Domain
# 4.1. Set Local Group Policy
# 5. Set Static IP 


param ($domain, $timezone, $setip, $servname, $workgroup )
$os = $false

## OS Check
If ( Get-CimInstance Win32_OperatingSystem | Select-Object Caption -match 'Server' ) {
    $os = $true
}

## Set Timezone
If ( $timezone ) {
    Set-TimeZone $timezone
} 

## Change System Name
If ( $servname ) {
    netdom renamecomputer $env:COMPUTERNAME /newname:$servname
}

## Join Domain | Setup Local Group Policy
If ( $domain ) {
    Add-Computer -DomainName $domain
    If ( $os ) {
        ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -WSMember -Force
    } Else { ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -Win10DomainJoined -Force }
}

## Join Workgroup | Setup Local Group Policy
If ( $workgroup ) {
    Add-Computer -WorkgroupName $workgroup
    If ( $os ) {
        ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -WSNonDomainJoined -Force
    } Else { ./Windows10_V1909_WindowsServer_V1909_Security_Baseline/Scripts/Baseline-LocalInstall.ps1 -Win10NonDomainJoined -Force }
}

## Set Static Host Network Configuration
If ( $setip ) {
    New-NetIPAddress
    Set-DnsClientServerAddress
}

