## Author: W.Bansbach ##
## Post Installation PowerShell Script ##
<# Properly configures and hardens a Windows Server 2016 Installation
Based on commands found in MCSA Guide to Installation, Storage,
and Compute with Windows Server 2016 - Greg Tomsho
#>

param ($domain, $timezone, $setip, $servname, $workgroup )
$isserver = $false
$os = Get-CimInstance Win32_OperatingSystem | Select-Object Caption

function Manual {
    Write-Host "
    POST Help
   -----------------------------------
    -domain [Domain Name]               Connects the host to the specified domain
    -timezone [Standard Time Zone]      Sets the system timezone.
    -setip [$true] or [1]               Sets hosts network configuration
    -servname [Server Name]             Set host system name to specified server name
    -workgroup [Workgroup Name]         Connects host to the specified workgroup 
    "
}

## Check Arguments
If ($args.Length -eq 0) {
    Manual
}

## OS Check
If ( $os -match 'Server' ) {
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

