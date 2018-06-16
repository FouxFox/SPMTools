#Set Variables
Function InitTestVariables {
	$Param = @{
		Name = 'DefaultCompanyName'
		Option = 'ReadOnly'
		Scope = 'Global'
		Value = 'TestCompany'
	}
	Set-Variable @Param

	$TestPassword = ConvertTo-SecureString -Force -AsPlainText -String "password"
	$Param = @{
		Name = 'DefaultTestCredential'
		Option = 'ReadOnly'
		Scope = 'Global'
		Value = New-Object System.Management.Automation.PSCredential ("username",$TestPassword)
	}
	Set-Variable @Param

	$Param = @{
		Name = 'DefaultConfig'
		Option = 'ReadOnly'
		Scope = 'Global'
		Value = @{
			Companies = @{
				$DefaultCompanyName = @{
					Domain = @{
						PSDriveLetter = 'EX'
						FQDN = 'example.com'
						PreferedDomainController = $false
						Favorite = $false
						CredentialName = "AD_$DefaultCompanyName"
					}
					OnPremServices =  @{
						Exchange = @{
							Uri = 'http://ExchangeServer.example.com/PowerShell/'
						}
						Skype = @{
							Uri = 'https://SkypeFE.example.com/OCSPowerShell'
						}
						CredentialName = "OnPrem_$DefaultCompanyName"
					}
					O365 = @{
						Mfa = $true
						ExchangeOnlineUri = 'https://outlook.office365.com/powershell-liveid/'
						SkypeOnlineUri = 'https://online.lync.com/OCSPowerShell'
						CredentialName = "O365_$DefaultCompanyName"
					}
				} 
			}
		}
	}
	Set-Variable @Param
	Set-Variable -Scope Script -Name ScriptTest -Value 1
	Set-Variable -Scope Local -Name LocalTest -Value 1
}

Function RemoveTestVariables {
	$Vars = @(
		'DefaultCompanyName'
		'DefaultTestCredential'
		'DefaultConfig'
	)
	$vars | ForEach-Object {
		Remove-Variable $_ -Force -Scope Global
	}
}

function Clone-Object {
    param($DeepCopyObject)
    $memStream = new-object IO.MemoryStream
    $formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $formatter.Serialize($memStream,$DeepCopyObject)
    $memStream.Position=0
    $formatter.Deserialize($memStream)
}

