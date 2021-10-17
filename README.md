# Post Installation Utility
--------------------------------------------------
# Documentation:
* Parameters
  > DomainName [Domain Name]          - [Optional] Connects the host to specified domain
  > Timezone [Standard Time Zone]     - [Optional] Sets the host timezone
  > SetIp [$true] or [1]              - [Optional] Runs network cmdlet
  > ServerName [Server Name]          - [Mandatory] Set the host system name
  > WorkgroupName [Workgroup Name]    - [Optional] Set the host workgroup name
                   
* Logging
  > Is completed via some goodies found in the comments here: https://community.spiceworks.com/topic/1233789-add-logging-to-powershell-script
  > Logs: [Current_Working_Directory]\Log\PostInstall.ps1-[Date].log
--------------------------------------------------
Change Log:
* 10/16/2021
  - Updated Synopsis, Documentation, and Known Issues sections
  - Changed Parameter & Variable names
  - Explicitly defined parameter datatypes
  - Added a Connection Test after configuration
  - Changed the NetSet Param
* 10/17/2021
  - Added UpdateHost function
  - Moved NetConnection to UpdateHost before depedencies are installed
  - Added Logging
--------------------------------------------------
Known Issues:
1. [SOLVED] For all features to work, script must be ran as Administrator (Requires RunAsAdministrator - Line #43)
2.
--------------------------------------------------
