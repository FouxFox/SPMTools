#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

#Inital Setup

#Functions
Import-Module $Script:ModulePath


#Tests
Describe SPMTools.Public.Connect-ExchangeOnline {
    InModuleScope SPMTools {
        $CompanyName = 'TestCompany'
        $TestPassword = ConvertTo-SecureString -Force -AsPlainText -String "password"
        $TestCredential = New-Object System.Management.Automation.PSCredential ("username",$TestPassword)
        
        <#
        Purpose:         Converts the Configuration from JSON to a HashTable
        Action:          Read-SPMTConfiguration
        Expected Result: ConvertTo-HashTable is loaded into $Script:Config
        #>
        Context 'Read Default Configuration' {
            #Setup Variables
            $OldSessionObj = @{
                ConfigurationName = 'Microsoft.Exchange'
            }
            $SessionParameters = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = 'https://outlook.office365.com/powershell-liveid'
		        Authentication = "Basic"
		        AllowRedirection = $true
		        Credential = $TestCredential
	        }
            
            #Set Module Configuration
            New-Company -Name $CompanyName
            Set-Company -Name $CompanyName -OnlineNoMFA -OnlineCredential $TestCredential

            #Mock Methods
            Mock Get-PSSession { return $OldSessionObj }
            Mock Remove-PSSession {}
            Mock Get-StoredCredential { return $TestCredential }
            Mock New-PSSession { return "Test" }
            Mock Import-PSSession {}

            #Run Function
            Connect-ExchangeOnline -Company $CompanyName

            It 'Removes Old Sessions' {
                Assert-MockCalled Get-PSSession
                Assert-MockCalled Remove-PSSession -ParameterFilter { $Session -eq $OldSessionObj }
            }
            It 'Gets credentials from the credential vault' {
                Assert-MockCalled Get-StoredCredential -ParameterFilter { $Target -eq "O365_$CompanyName" }
            }
            It "Creates a session with a ConnectionURI of '$($SessionParameters.ConfigurationName)'" {
                Assert-MockCalled New-PSSession -ParameterFilter { $ConfigurationName -eq $SessionParameters.ConfigurationName }
            }
            It "Creates a session with a ConnectionURI of '$($SessionParameters.ConnectionURI)'" {
                Assert-MockCalled New-PSSession -ParameterFilter { $Credential -eq $TestCredential }
            }
            It "Creates a session using '$($SessionParameters.ConnectionURI)' Authentication" {
                Assert-MockCalled New-PSSession -ParameterFilter { $Authentication -eq $SessionParameters.Authentication }
            }
            It "Creates a session that Allows Redirection" {
                Assert-MockCalled New-PSSession -ParameterFilter { $AllowRedirection -eq $true }
            }
            It "Creates a session with the provided credentials" {
                Assert-MockCalled New-PSSession -ParameterFilter { $Credential -eq $TestCredential }
            }
            It "Calls Import-PSSession" {
                Assert-MockCalled Import-PSSession
            }
        }
        Remove-Company -Name $CompanyName
    }
}

#Cleanup

Remove-Module SPMTools