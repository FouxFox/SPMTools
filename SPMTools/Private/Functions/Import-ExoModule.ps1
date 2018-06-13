function Import-EXOModule {
    [CmdletBinding()]  
    Param()

    #Check if module is installed
    $ApplicationName = "Microsoft Exchange Online Powershell Module"
    $ApplicationKeys = Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall
    
    $IsInstalled = $ApplicationKeys | Where-Object {
        $_.DisplayName -match $ApplicationName 
    } | Select-Object -First 1

    #If not, install it
    if(!$IsInstalled) {
        Install-EXOModule
    }

    #Finally import the module
    $LocalPath = $env:LOCALAPPDATA + "\Apps\2.0\"
    $DLLName = 'Microsoft.Exchange.Management.ExoPowershellModule.dll'
    
    $Param = @{
        Path = $LocalPath
        Filter = $DLLName
        Recurse = $true
    }
    $Module = (Get-ChildItem @Param).FullName | Where-Object { $_ -notmatch "_none_" } | Select-Object -First 1

    if($Module) {
        Try {
            Import-Module $Module
        }
        Catch {
            Write-Error -Message "The ExchangeOnlineMFA Module could not be imported: $($_.Exception.Message)"
        }
    }
}