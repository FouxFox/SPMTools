#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.New-ADDrive {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {
        Context 'Loadng Drive (PSProvider Available / No PDC / No Credential)' {
            #Setup Variables
            $DomainObj = Copy-Object $DefaultConfig.Companies.$DefaultCompanyName.Domain
            $DomainObj.CredentialName = $false

            #PSProvider Mock
            Function New-PSDrive { Param(
                [string]$Name,
                [string]$PSProvider,
                [string]$Root,
                [string]$Scope,
                [string]$Server
            )}

            #Mocks
            Mock Get-PSDrive { Throw }
            Mock New-PSDrive {}
            Mock Get-PSProvider {}
            Mock Import-Module {}
            Mock Remove-Module {}

            #Run Statement
            New-ADDrive $DomainObj

            #Tests
            It 'Checks for the PSProvider' {
                $Param = @{
                    CommandName = 'Get-PSProvider'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $PSProvider -eq 'ActiveDirectory'
                    }
                }
                Assert-MockCalled @Param 
            }
            It 'Does not manipulate the aviailible modules' {
                Assert-MockCalled -CommandName 'Import-Module' -Exactly -Times 0
                Assert-MockCalled -CommandName 'Remove-Module' -Exactly -Times 0
            }
            It 'Checks for existing drives' {
                $Param = @{
                    CommandName = 'Get-PSDrive'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq $DomainObj.PSDriveLetter
                    }
                }
                Assert-MockCalled @Param 
            }
            It 'Creates the Drive' {
                $Param = @{
                    CommandName = 'New-PSDrive'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq $DomainObj.PSDriveLetter -and
                        $PSProvider -eq 'ActiveDirectory' -and
                        $Root -eq '' -and
                        $Scope -eq 'Global' -and
                        $Server -eq $DomainObj.FQDN
                    }
                }
                Assert-MockCalled @Param 
            }
        }

        Context 'Loadng Drive (PSProvider Unavailable / PDC / Credential)' {
            #Setup Variables
            $DomainObj = Copy-Object $DefaultConfig.Companies.$DefaultCompanyName.Domain
            $DomainObj.PreferedDomainController = 'Test.example.com'
            $TestCredential = $DefaultTestCredential

            #PSProvider Mock
            Function New-PSDrive { Param(
                [string]$Name,
                [string]$PSProvider,
                [string]$Root,
                [string]$Scope,
                [string]$Server,
                [pscredential]$Credential
            )}

            #Mocks
            Mock Get-PSDrive { Throw }
            Mock New-PSDrive {}
            Mock Get-PSProvider {
                $Ex = New-Object System.Management.Automation.ProviderNotFoundException
                Throw $Ex 
            }
            Mock Import-Module {}
            Mock Remove-Module {}
            Mock Get-StoredCredential { return $TestCredential }

            #Run Statement
            New-ADDrive $DomainObj

            #Tests
            It 'Removes and ReImports the AD Module' {
                $Param = @{
                    CommandName = 'Remove-Module'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq 'ActiveDirectory' -and
                        $Force -eq $true
                    }
                }
                Assert-MockCalled @Param 
                $Param = @{
                    CommandName = 'Import-Module'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq 'ActiveDirectory'
                    }
                }
                Assert-MockCalled @Param 
            }
            It 'Creates the Drive' {
                $Param = @{
                    CommandName = 'New-PSDrive'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq $DomainObj.PSDriveLetter -and
                        $PSProvider -eq 'ActiveDirectory' -and
                        $Root -eq '' -and
                        $Scope -eq 'Global' -and
                        $Server -eq $DomainObj.PreferedDomainController -and
                        $Credential -eq $TestCredential
                    }
                }
                Assert-MockCalled @Param 
            }
        }

        Context 'Loadng Drive (PSDrive Letter Used)' {
            #Setup Variables
            $DomainObj = Copy-Object $DefaultConfig.Companies.$DefaultCompanyName.Domain
            $DomainObj.CredentialName = $false
            $ErrorText = "The drive '$($DomainObj.PSDriveLetter)' exists. Please unmount it before calling '$($PSCmdlet.MyInvocation.InvocationName)' again"

            #Mocks
            Mock Get-PSDrive {}
            Mock New-PSDrive {}
            Mock Get-PSProvider {}
            Mock Import-Module {}
            Mock Remove-Module {}

            #Tests
            It 'Throws an error' {
                { New-ADDrive $DomainObj } | Should Throw $ErrorText
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools