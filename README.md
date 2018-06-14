# SPMTools
Management Tools for Service Providers
The Service Provider Management Tools (SPMTools) module provides engineers with the ability to store connection information and use it quickly, eliminating the need to constantly retype passwords or maintain the same password across all companies serviced by the engineer to simplify the logon process. 

## Getting Started
#### Steps
* Install the module (You may need to use an administrative Powershell Window)
    ```powershell
    Install-Module SPMTools
    ```
* Run PowerShell under the user account you intend to use for day to day work.
    - If you have an administrator account that already has access to many resources, this will simplify configuration.
    - You can open PowerShell as another user by Shift-Right Clicking the icon on the taskbar.
* Create a new company profile
    ```powershell
    New-Company -Name ExampleServices
    ```
* Configure the company profile
    - Set Domain settings
    ```powershell
    Set-Company -Name ExampleServices -ADDriveName ES -ADFQDN example.local -ADCredential example\adminuser
    ```
    - Set On-Premise Services settings
    ```powershell
    Set-Company -Name ExampleServices -OnPremExchangeHost mail.example.local -OnPremCredential example\adminuser
    ```
    -Set Office365 settings
    ```powershell
    Set-Company -Name ExampleServices -OnlineNoMFA -OnlineCredential adminuser@example.onmicrosoft.com
    ```
* Start using SPMTools!
    - Most `Connect-` commands have a single parameter for `Company`. These commands will also allow that parameter to be tab completed.
    - `Mount-ADDrive` can be used to mount the AD Drives from one or more companies.
* Mount Drives at startup
    - Run `'Mount-ADDrive -Favorites' | Out-File -Append -FilePath $PROFILE` to add this command to your PowerShell profile load your favorite drives when you launch PowerShell.
    - Run `'Mount-ADDrive' | Out-File -Append -FilePath $PROFILE` to add this command to your PowerShell profile load all drives when you launch PowerShell.