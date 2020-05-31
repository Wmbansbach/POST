# POST
Post Installation Hardening Script
Windows Server / Windows 10

# Dependencies
1. Windows10_V1909_WindowsServer_V1909_Security_Baseline
2. LGPO - Local Group Policy Object Utility
> ** Both files can be found within the Microsoft Security Compliance Toolkit 1.0

# Use
1. Download and Extract Security Baseline, LGPO, and PostInstall
2. Place LGPO into C:\..\Windows10_V1909_WindowsServer_V1909_Security_Baseline\Scripts\Tools
3. Place both PostInstall.ps1 and Windows10_V1909_WindowsServer_V1909_Security_Baseline in the same directory
4. Ensure Execution Policy is set to Unrestricted
    - Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
5. Execute script
    - ./PostInstall.ps1
   
