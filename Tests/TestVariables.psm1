#Set Variables
Function InitTestVariables {
	$Param = @{
		Name = 'DefaultCompanyName'
		Option = 'ReadOnly'
		Scope = 'Global'
		Value = 'TestCompany'
	}
	Set-Variable @Param

	$Param = @{
		Name = 'DefaultCompanyName2'
		Option = 'ReadOnly'
		Scope = 'Global'
		Value = 'TestCompany2'
	}
	Set-Variable @Param

	$TestPassword = ConvertTo-SecureString -Force -AsPlainText -String "password"
	$Param = @{
		Name = 'DefaultTestCredential'
		Option = 'ReadOnly'
		Scope = 'Global'
		Value = New-Object System.Management.Automation.PSCredential ("u@example.onmicrosoft.com",$TestPassword)
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
						ExchangeUri = 'http://ExchangeServer.example.com/PowerShell/'
						SkypeUri = 'https://SkypeFE.example.com/OCSPowerShell'
						CredentialName = "OnPrem_$DefaultCompanyName"
					}
					O365 = @{
						Mfa = $true
						ExchangeOnlineUri = 'https://outlook.office365.com/powershell-liveid/'
						SkypeOnlineUri = 'https://online.lync.com/OCSPowerShell'
						SharePointUri = $false
						ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
						CredentialName = "O365_$DefaultCompanyName"
					}
				}
				$DefaultCompanyName2 = @{
					Domain = @{
						PSDriveLetter = 'OR'
						FQDN = 'org.com'
						PreferedDomainController = 'testdc.org.com'
						Favorite = $true
						CredentialName = "AD_$DefaultCompanyName2"
					}
					OnPremServices =  @{
						ExchangeUri = $false
						SkypeUri = $false
						CredentialName = $false
					}
					O365 = $false
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
		'DefaultCompanyName2'
		'DefaultTestCredential'
		'DefaultConfig'
	)
	$vars | ForEach-Object {
		Remove-Variable $_ -Force -Scope Global
	}
}

#Pulled from https://stackoverflow.com/questions/7468707/deep-copy-a-dictionary-hashtable-in-powershell
function Copy-Object {
    param($DeepCopyObject)
    $memStream = new-object IO.MemoryStream
    $formatter = new-object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $formatter.Serialize($memStream,$DeepCopyObject)
    $memStream.Position=0
    $formatter.Deserialize($memStream)
}

#To uninstall the Click Once App for testing
# Simple UnInstall
function Uninstall-ExoModule {
    [CmdletBinding()] 
    Param(
        $ApplicationName = "Microsoft Exchange Online Powershell Module"
    )
        $app=Get-ClickOnce -ApplicationName $ApplicationName
    
        #Deinstall One to remove all instances
        if ($App) { 
            $selectedUninstallString = $App.UninstallString 
            #Seperate cmd from parameters (First Space)
            $parts = $selectedUninstallString.Split(' ', 2)
            Start-Process -FilePath $parts[0] -ArgumentList $parts[1] -Wait 
            #ToDo : Automatic press of OK
            #Start-Sleep 5
            #$wshell = new-object -com wscript.shell
            #$wshell.sendkeys("`"OK`"~")
    
            $app=Get-ClickOnce -ApplicationName $ApplicationName
            if ($app) {
                Write-verbose 'De-installation aborted'
                #return $false
            } else {
                Write-verbose 'De-installation completed'
                #return $true
            } 
            
        } else {
            #return $null
        }
    }
    #>