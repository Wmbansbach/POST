# POST
Post Installation Hardening Script
Windows Server / Windows 10

> **Microsoft Security Compliance Toolkit 1.0 is required to 

# Setup
1. Download and Extract Security Baseline, LGPO, and PostInstall
2. Place LGPO into C:\..\Windows10_V1909_WindowsServer_V1909_Security_Baseline\Scripts\Tools
3. Place both PostInstall.ps1 and Windows10_V1909_WindowsServer_V1909_Security_Baseline in the same directory

# Use
-domain [Domain Name]
    Connects the host to the specified domain
    
-timezone [Standard Time Zone]
    Sets the system timezone
    
-setip [$true]
    Sets hosts network configuration
    
-servname [Server Name]
    Set host system name to specified server name
    
-workgroup [Workgroup Name]
    Connects host to the specified workgroup
    
-gpo [$false]
    Set to false, if no GPO changes are needed
   
