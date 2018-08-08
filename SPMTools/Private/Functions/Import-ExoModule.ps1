function Import-EXOModule {
    [CmdletBinding()]  
    Param()

    #Check if module is installed
    $ApplicationName = "Microsoft Exchange Online Powershell Module"
    Try {
        $Param = @{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
            ErrorAction = 'Stop'
        }
        $ApplicationKeys = Get-ChildItem @Param

        $IsInstalled = $ApplicationKeys | Where-Object {
            $_.DisplayName -match $ApplicationName 
        } | Select-Object -First 1
    }
    Catch {
        Write-Verbose "No Applications Installed for this user"
    }

    #If not, install it
    if(!$IsInstalled) {
        Install-EXOModule
    }

    #Finally import the module
    $LocalPath = $env:LOCALAPPDATA + "\Apps\2.0\"
    $DLLName = 'Microsoft.Exchange.Management.ExoPowershellModule.dll'
    
    $Filter = { $_ -notmatch "_none_" }
    $Param = @{
        Path = $LocalPath
        Filter = $DLLName
        Recurse = $true
    }
    $Module = (Get-ChildItem @Param).FullName | Where-Object $Filter | Select-Object -First 1

    if($Module) {
        Try {
            Import-Module $Module
        }
        Catch {
            Write-Error -Message "The ExchangeOnlineMFA Module could not be imported: $($_.Exception.Message)"
        }
    }
}