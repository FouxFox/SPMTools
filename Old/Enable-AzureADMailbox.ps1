<#
.SYNOPSIS
Enables a user's mailbox in Office365.


.DESCRIPTION
Enable-AzureADMailbox enables a remote mailbox for a user and licenses them.


.PARAMETER $UserPrincipalName 
The UserPrincipalName of the user to be enabled. 
Can be piped from Get-ADUser.


.PARAMETER $PrimarySuffix
The suffix of the users send from email.
This should be the part after the '@' sign without including the '@'.


.PARAMETER $AzureSku
The license tier for the user. 
This parameter supports tab-completion. Default is E1.


.EXAMPLE
Enable the O365 mailbox for Latisha.Example@example.com as an E3 Sku 
with a send from email of Larisha.Example@example.com
Enable-AzureADMailbox -UserPrincipalName Latisha.Example@example.com -AzureSku E3

.EXAMPLE
Enable the O365 mailbox for Person.Example@example.com as an E1 Sku 
with a send from email of Person.Example@gmail.com
Enable-AzureADMailbox -UserPrincipalName Person.Example@example.com -PrimarySuffix gmail.com

.NOTES
This command requires:
 - AzureAD Module
 - Connect- Cmdlets

#>
Function Enable-AzureADMailbox {
    [cmdletBinding()] 
    Param(
	    [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Mandatory=$True
        )] 
	    [string]$UserPrincipalName, 
        [Parameter(Mandatory=$false)] 
	    [string]$PrimarySuffix
    )
    DynamicParam {
        $ParameterName = 'AzureSku'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $false
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute([string[]]$AzureSkuTable.Keys)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }

    Begin {
        #Configuration Options
        $Configuration = @{
	        RemoteRoutingSuffix = "tenant.mail.onmicrosoft.com"
	        AzureUsageLocation  = "US"
        }

        #A List of UPN Suffix to Domain Names
        $UPNSuffixes = @{
	        'domain.com' = 'Domain'
        }

        $DomainList = @{
	        'Domain' = @{
		        DomainSuffix = ''
		        DirSyncHost = ''
		        ExchangeHost = ''
				DomainController = $AD['']
	        }
        }

        
    }
    Process {
		#Set up Variables
		if(!$UPNSuffixes.ContainsKey($UserPrincipalName.ToLower().Split('@')[1])) {
			Throw "UPN not valid. Please check UPNSuffix List in this cmdlet."
		}
		if(!$PSBoundParameters.AzureSku) {
			$AzureSku = $AzureSkuTable['E1']
		}
		else {
			$AzureSku = $AzureSkuTable[$PSBoundParameters.AzureSku]
		}
        $Company = $UPNSuffixes[$UserPrincipalName.ToLower().Split('@')[1]]
        $DomainConfig = $DomainList[$Company]
        $User = ""

        #Initiate Connections
        $Connectivity = $false
        Try {
	        #Connect to Exchange
            $ExchangeSessionState = Get-PSSession | Where-Object { 
                $_.ComputerName -eq $DomainConfig.ExcahngeHost -and
                $_.ComputerName -eq "Microsoft.Exchange" -and
                $_.State -ne "Broken"
            }

            if(!$ExchangeSessionState) {
				Write-Host "Connecting to On-Premise Exchange..."
                $null = Connect-ExchangeOnPrem -OpCo $Company -Verbose:$false
            }

	        #Connect to AzureAD
            Try {
                Get-AzureADTenantDetail 
            }
            Catch {
				Write-Host "Connecting to AzureAD..."
	            $null = Connect-AzureAD -Verbose:$false
            }

	        #Write Connectivity True
	        $Connectivity = $true
        }
        Catch {
	        $_
        }
		
        if($Connectivity) {
	        #Get Local AD User
            Write-Progress -Activity "Finding User in AD" -Status "Step 1 of 5" -PercentComplete 0
	        Try {
		        $Param = @{
			        Filter = { UserPrincipalName -eq $UserPrincipalName }
			        Server = $DomainConfig.DomainSuffix
			        ErrorAction = "Stop"
		        }
		        $User = Get-ADUser @Param
		        if(!$User) {
			        Throw #I'm Paranoid
		        }
                Write-Verbose "INFO : User $UserPrincipalName found in local AD"
	        }
	        Catch {
                Write-Error "Acitve Directory - Error : User $UserPrincipalName not found"
	        }

	        #Get AzureADUser Object
            Write-Progress -Activity "Finding User in AzureAD" -Status "Step 2 of 5" -PercentComplete 20
	        Try {
		        $AzureADUser = Get-AzureADUser -ObjectID $UserPrincipalName -ErrorAction Stop
		        if(!$AzureADUser) {
			        Throw #I'm Paranoid
		        }
                Write-Verbose "INFO : User $UserPrincipalName found in AzureAD (O365)"
	        }
	        Catch {
                Write-Error "AzureAD - Error: User $UserPrincipalName not found in AzureAD (O365)"
	        }

	        if($User -and $AzureADUser) {
		        $ProcessError = $false

		        #Enable Mailbox in OnPrem Exchange
                Write-Progress -Activity "Enabling Remote Mailbox in Exchange" -Status "Step 3 of 5" -PercentComplete 30
		        Try {
					$EOPSession = Get-PSSession | Where-Object {
						$_.ComputerName -eq $DomainConfig.ExcahngeHost -and
						$_.Availability -eq "Available"
						$_.State -eq "Opened"
					}
					$Block = {
						param($p1)
						Enable-RemoteMailbox @p1
					}
                    $Param = @{
				        Identity = $User.SamAccountName
						DomainController = $DomainConfig.DomainController
				        RemoteRoutingAddress = "$($User.UserPrincipalName.Split('@')[0])@$($Configuration.RemoteRoutingSuffix)"
			        }
			        $null = Invoke-Command -Session $EOPSession -ScriptBlock $Block -ArgumentList $Param -ErrorAction Stop
                    Write-Verbose "INFO : User $UserPrincipalName provisioned in Exchange On-Premise"
		        }
		        Catch {
			        $ProcessError = $true
                    Write-Error "Mailbox Creation - Error: $($_.Exception.Message)"
		        }
				
				#Provision PrimarySuffix
				if(!$ProcessError) {
                    Write-Progress -Activity "Provisioning Primary Suffix" -Status "Step 3 of 5" -PercentComplete 40

					While ((Get-ADUser $User.SamAccountName -Properties ProxyAddresses).ProxyAddresses.count -lt 1) {
						Start-Sleep -Seconds 10
					}
					$ProxyAddresses = (Get-ADUser $User.SamAccountName -Properties ProxyAddresses).ProxyAddresses
					$CurrentAddress =  $ProxyAddresses | Where-Object { $_.Contains("SMTP:") }
					if($PrimarySuffix -and !$CurrentAddress.Split('@')[1].ToLower() -eq $PrimarySuffix.ToLower()) {
						Set-ADUser $User.SamAccountName -Remove @{ProxyAddresses=$CurrentAddress}
						
						$NewAddressList = @()
						$NewAddressList += "SMTP:$($User.UserPrincipalName.Split('@')[0])@$PrimarySuffix"
						$NewAddressList += $CurrentAddress.Replace('SMTP','smtp')
						Set-ADUser $User.SamAccountName -Add @{ProxyAddresses=$NewAddressList}
					}
				}

		        #Run a Delta Sync of AD to AzureAD
		        if(!$ProcessError) {
                    Write-Progress -Activity "Running DirSync (60 Seconds)" -Status "Step 4 of 5" -PercentComplete 50
			        Try {
				        $null = Invoke-Command -ComputerName $DomainConfig.DirSyncHost -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }
                        Write-Progress -Activity "Running DirSync (60 Seconds)" -Status "Step 4 of 5" -PercentComplete 60
				        Start-Sleep -Seconds 60
                        Write-Verbose "INFO : DirSync executed on $($DomainConfig.DirSyncHost)"
			        }
			        Catch {
				        $ProcessError = $true
                        Write-Error "DirSync - Error: $($_.Exception.Message)"
			        }
		        }

		        #Fetch Azure Sku Object
		        if(!$ProcessError) {
                    Write-Progress -Activity "Licensing User" -Status "Step 5 of 5" -PercentComplete 70
			        Try {
				        $sku = (Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq $AzureSku }).SkuId
				        $AssignedLicenses = New-Object Microsoft.Open.AzureAD.Model.AssignedLicenses
				        $AssignedLicenses.AddLicenses = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
				        $AssignedLicenses.AddLicenses[0].SkuId = $sku
			        }
			        Catch {
				        $ProcessError = $true
                        Write-Error "License Type Check - Error: $($_.Exception.Message)"
			        }
		        }
					

		        #License the user
		        if(!$ProcessError) {
                    Write-Progress -Activity "Licensing User" -Status "Step 5 of 5" -PercentComplete 80
			        Try {
				        $AzureADUser | Set-AzureADUser -UsageLocation $Configuration.AzureUsageLocation
				        $AzureADUser | Set-AzureADUserLicense -AssignedLicenses $AssignedLicenses
                        Write-Verbose "INFO :User $upn licensed in AzureAD (O365)"
			        }
			        Catch {
				        $ProcessError = $true
                        Write-Error "User Licensing - Error: $($_.Exception.Message)"
			        }
		        }

		        #Write Output
		        if(!$ProcessError) {
			        Write-Progress -Completed -Activity "Done"
                    Write-Host -BackgroundColor Black -ForegroundColor Green "SUCCESS : $($User.Name) enabled and Licensed"
					Write-Host -BackgroundColor Black -ForegroundColor Yellow "INFO : It may take up to 1 hour for changes to propagate in O365"
		        }
	        }
        }
    }
}