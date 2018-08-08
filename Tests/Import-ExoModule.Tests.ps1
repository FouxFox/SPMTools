#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Import-ExoModule {
    InModuleScope SPMTools {
        Context 'Module is installed' {

            #Mocks
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
                }
                MockWith = {
                    return @(
                        [pscustomobject]@{
                            DisplayName = 'Microsoft Exchange Online Powershell Module'
                        }
                        [pscustomobject]@{
                            DisplayName = 'Microsoft Exchange Online Powershell Module v2'
                        }
                    )
                }
            }
            Mock @Param #Get Child Item for Reg
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq "$($env:LOCALAPPDATA)\Apps\2.0\" -and
                    $Filter -eq 'Microsoft.Exchange.Management.ExoPowershellModule.dll' -and
                    $Recurse -eq $true
                }
                MockWith = {
                    return @(
                        [pscustomobject]@{
                            #With None
                            FullName = 'C:\Users\user\AppData\Local\Apps\2.0\8CQCDPNB.DVH\6OKQMOY5.HX7\micr..dule_31bf3856ad364e35_0010.0000_none_e092d310eab729ab\Microsoft.Exchange.Management.ExoPowershellModule.dll'
                        }
                        [pscustomobject]@{
                            #Without None
                            FullName = 'C:\Users\user\AppData\Local\Apps\2.0\8CQCDPNB.DVH\6OKQMOY5.HX7\micr..tion_a8eee8aa09b0c4a7_0010.0000_46a3c36b19dd5128\Microsoft.Exchange.Management.ExoPowershellModule.dll'
                        }
                    )
                }
            }
            Mock @Param #Get Child Item for FilePath
            Mock Install-ExoModule {}
            Mock Import-Module {}

            #Run Statement
            Import-EXOModule

            #Tests
            It 'Check if ExoModule is installed' {
                $Param = @{
                    CommandName = 'Get-ChildItem'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Does not attempt to install the Module' {
                Assert-MockCalled Install-ExoModule -Exactly -Times 0
            }
            It 'Checks for the DLL' {
                $Param = @{
                    CommandName = 'Get-ChildItem'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Path -eq $env:LOCALAPPDATA + '\Apps\2.0\' -and
                        $Filter -eq 'Microsoft.Exchange.Management.ExoPowershellModule.dll' -and
                        $Recurse -eq $true
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Attempts to import the DLL' {
                Assert-MockCalled Import-Module -Exactly -Times 1
            }
        }

        Context 'Module is not installed' {

            #Mocks
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
                }
                MockWith = {}
            }
            Mock @Param #Get Child Item for Reg
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq "$($env:LOCALAPPDATA)\Apps\2.0\" -and
                    $Filter -eq 'Microsoft.Exchange.Management.ExoPowershellModule.dll' -and
                    $Recurse -eq $true
                }
                MockWith = {
                    return @(
                        [pscustomobject]@{
                            #With None
                            FullName = 'C:\Users\user\AppData\Local\Apps\2.0\8CQCDPNB.DVH\6OKQMOY5.HX7\micr..dule_31bf3856ad364e35_0010.0000_none_e092d310eab729ab\Microsoft.Exchange.Management.ExoPowershellModule.dll'
                        }
                        [pscustomobject]@{
                            #Without None
                            FullName = 'C:\Users\user\AppData\Local\Apps\2.0\8CQCDPNB.DVH\6OKQMOY5.HX7\micr..tion_a8eee8aa09b0c4a7_0010.0000_46a3c36b19dd5128\Microsoft.Exchange.Management.ExoPowershellModule.dll'
                        }
                    )
                }
            }
            Mock @Param #Get Child Item for FilePath
            Mock Install-ExoModule {}
            Mock Import-Module {}

            #Run Statement
            Import-EXOModule

            #Tests
            It 'Attempts to install the Module' {
                Assert-MockCalled Install-ExoModule -Exactly -Times 1
            }
        }

        Context 'No Applications are installed' {

            #Mocks
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
                }
                MockWith = { Throw }
            }
            Mock @Param #Get Child Item for Reg
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq "$($env:LOCALAPPDATA)\Apps\2.0\" -and
                    $Filter -eq 'Microsoft.Exchange.Management.ExoPowershellModule.dll' -and
                    $Recurse -eq $true
                }
                MockWith = {
                    return @(
                        [pscustomobject]@{
                            #With None
                            FullName = 'C:\Users\user\AppData\Local\Apps\2.0\8CQCDPNB.DVH\6OKQMOY5.HX7\micr..dule_31bf3856ad364e35_0010.0000_none_e092d310eab729ab\Microsoft.Exchange.Management.ExoPowershellModule.dll'
                        }
                        [pscustomobject]@{
                            #Without None
                            FullName = 'C:\Users\user\AppData\Local\Apps\2.0\8CQCDPNB.DVH\6OKQMOY5.HX7\micr..tion_a8eee8aa09b0c4a7_0010.0000_46a3c36b19dd5128\Microsoft.Exchange.Management.ExoPowershellModule.dll'
                        }
                    )
                }
            }
            Mock @Param #Get Child Item for FilePath
            Mock Install-ExoModule {}
            Mock Import-Module {}

            #Run Statement
            

            #Tests
            It 'Catchs the error' {
                { Import-EXOModule } | Should Not Throw
            }
            It 'Attempts to install the Module' {
                Assert-MockCalled Install-ExoModule -Exactly -Times 1
            }
        }

        Context 'Module fails to install' {

            #Mocks
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
                }
                MockWith = {}
            }
            Mock @Param #Get Child Item for Reg
            $Param = @{
                CommandName = 'Get-ChildItem'
                ParameterFilter = {
                    $Path -eq "$($env:LOCALAPPDATA)\Apps\2.0\" -and
                    $Filter -eq 'Microsoft.Exchange.Management.ExoPowershellModule.dll' -and
                    $Recurse -eq $true
                }
                MockWith = {}
            }
            Mock @Param #Get Child Item for FilePath
            Mock Install-ExoModule { Throw }
            Mock Import-Module {}
            Mock Write-Error {}

            #Tests
            It 'Throws an error calling Install-ExoModule' {
                {Import-EXOModule} | Should Throw
            }
            It 'Does not attempt to import the DLL' {
                Assert-MockCalled Import-Module -Exactly -Times 0
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools