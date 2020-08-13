## Author: W.Bansbach ##
## Post Installation PowerShell Script ##
<# Configures and hardens a Windows Server 2016 Installation
Based on commands found in MCSA Guide to Installation, Storage,
and Compute with Windows Server 2016 - Greg Tomsho
#>

param ($domain, $timezone, $setip, $servname, $workgroup)

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

## Set Timezone
If ( $timezone ) {
    Set-TimeZone $timezone
} 

## Change System Name
If ( $servname ) {
    netdom renamecomputer $env:COMPUTERNAME /newname:$servname
}

## Join Domain
If ( $domain ) {
    Add-Computer -DomainName $domain
}

## Join Workgroup
If ( $workgroup ) {
    Add-Computer -WorkgroupName $workgroup
}

## Set Static Host Network Configuration
If ( $setip ) {
    New-NetIPAddress
    Set-DnsClientServerAddress
}

