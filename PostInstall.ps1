# Post Installation Utility
#--------------------------------------------------
# Synopsis:
# * Configures and hardens a Windows Server 2016 Installation
#   Based on commands found in MCSA Guide to Installation, Storage,
#   and Compute with Windows Server 2016 - Greg Tomsho
#
#--------------------------------------------------
# Documentation:
# * Parameters
#   > DomainName [Domain Name]          - [Optional] Connects the host to specified domain
#   > Timezone [Standard Time Zone]     - [Optional] Sets the host timezone
#   > SetIp [$true] or [1]              - [Optional] Runs network cmdlet
#   > ServerName [Server Name]          - [Mandatory] Set the host system name
#   > WorkgroupName [Workgroup Name]    - [Optional] Set the host workgroup name
#                   
# * Logging
#   > Is completed via some goodies found in the comments here: https://community.spiceworks.com/topic/1233789-add-logging-to-powershell-script
#   > Logs: [Current_Working_Directory]\Log\PostInstall.ps1-[Date].log
#
#--------------------------------------------------
# Change Log:
# * 10/16/2021
#   - Updated Synopsis, Documentation, and Known Issues sections
#   - Changed Parameter & Variable names
#   - Explicitly defined parameter datatypes
#   - Added a Connection Test after configuration
#   - Changed the NetSet Param
# * 10/17/2021
#   - Added UpdateHost function
#   - Moved NetConnection to UpdateHost before depedencies are installed
#   - Added Logging
#
#--------------------------------------------------
# Known Issues:
# 1. [SOLVED] For all features to work, script must be ran as Administrator (Requires RunAsAdministrator - Line #43)
# 2.
#--------------------------------------------------
# Notes:
# * Author - W.Bansbach
#
#--------------------------------------------------
#Requires -RunAsAdministrator

param (
    [Parameter(Mandatory=$false)]
    [string]$DomainName, 
    [Parameter(Mandatory=$false)]
    [string]$Timezone,
    [Parameter(Mandatory=$true)]
    [string]$HostName,
    [Parameter(Mandatory=$false)]
    [string]$WorkgroupName,
    [Parameter(Mandatory=$false)]
    [switch]$NetSetup
)

$ErrorActionPreference = "Stop"

# Logging Confiuration / Log Management
# Author: Martin9700
$VerbosePreference = "Continue"
$LogPath = Split-Path $MyInvocation.MyCommand.Path

# Check if Log directory exists
If ( -Not (Test-Path "$LogPath\Log") ) { 
    Write-Verbose "`r`n$(Get-Date): No Log directory found... Creating one`r`n"
    New-Item -Path "$LogPath" -Name "Log" -ItemType "Directory"
} Else {
    Write-Verbose "`r`n$(Get-Date): Log directory was found`r`n"
}

Get-ChildItem "$LogPath\Log\*.log" | Where LastWriteTime -LT (Get-Date).AddDays(-15) | Remove-Item -Confirm:$false
$LogPathName = Join-Path -Path "$($LogPath)\Log\" -ChildPath "$($MyInvocation.MyCommand.Name)-$(Get-Date -Format 'MM-dd-yyyy').log"
Start-Transcript $LogPathName -Append

# Windows Update Function
function UpdateHost(){
    # Check network connectivity
    $ConnStatus = Test-NetConnection -ComputerName 8.8.8.8

    If ($ConnStatus.PingSucceeded) {

        Write-Verbose "$(Get-Date): Connection Successful"

        ## NuGet utility needed for PSWindowsUpdate module install
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module PSWindowsUpdate -Force

        ## Check for Updates
        Get-WindowsUpdate

        ## Install any available Updates
        Install-WindowsUpdate -ForceInstall
    }
    Write-Verbose "$(Get-Date): Connection Unsuccessful"
}

## Set Timezone
If ( $Timezone ) { 
    Write-Verbose "$(Get-Date): Setting Timezone"
    Set-TimeZone $Timezone  
} 

## Change System Name
If ( $HostName ) { 
    Write-Verbose "$(Get-Date): Setting System Name"
    netdom renamecomputer $env:COMPUTERNAME /newname:$HostName
}

## Join Domain
If ( $DomainName ) { 
    Write-Verbose "$(Get-Date): Setting Domain Name"
    Add-Computer -DomainName $DomainName 
}

## Join Workgroup
If ( $WorkgroupName ) { 
    Write-Verbose "$(Get-Date): Setting Workgroup Name"
    Add-Computer -WorkgroupName $WorkgroupName 
}

## Set Static Host Network Configuration
If ( $NetSetup ) {
    New-NetIPAddress
    Set-DnsClientServerAddress
}

# Run Update Function
UpdateHost

# Complete Logging
Stop-Transcript






