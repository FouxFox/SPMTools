<#
.SYNOPSIS
Connects to On-Premise Skype for Business or Lync.

.DESCRIPTION
Connect-SkypeOnPrem uses information provided in the profile of the company specified
to connect to the specifiec company's on-premise skype or exchange server.

.PARAMETER Company
The company profile to use for connecting.
This parameter supports Tab-Completion.

.EXAMPLE
Connect-SkypeOnPrem -Company ExampleServices


.NOTES


#>

function Connect-SkypeOnPrem {
    [cmdletbinding()]
    Param()
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        
        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.OnPremServices.SkypeUri
        }
        if($ValidateSet.length -gt 0) {
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)
            $AttributeCollection.Add($ValidateSetAttribute)
        }
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        $Company = $PSBoundParameters.Company

        #Validation Error handling
        if(
            !$Script:Config.Companies.ContainsKey($Company) -or
            !$Script:Config.Companies.$Company.OnPremServices.SkypeUri
        ) {
            $message = "There is not a company profile available that supports this cmdlet. Please check your configuration and try again."
            $Param = @{
                ExceptionName = "System.ArgumentException"
                ExceptionMessage = $message
                ErrorId = "SkypeOnPremNoCompaniesAvailable" 
                CallerPSCmdlet = $PSCmdlet
                ErrorCategory = 'InvalidArgument'
            }
            ThrowError @Param
        }

        $CompanyObj = $Script:Config.Companies.$Company

	    $Param = @{
		    ConnectionURI = $CompanyObj.OnPremServices.SkypeUri
        }
        if($CompanyObj.OnPremServices.CredentialName) {
            $Credential = Get-StoredCredential -Target $CompanyObj.OnPremServices.CredentialName
            $Param.Add('Credential',$Credential)
        }
        
        $SBOSession = $false
        $SBOSession = New-PSSession @Param

        if($SBOSession) {
            $Param = @{
                Session = $SBOSession
                AllowClobber = $true
                DisableNameChecking = $true
            }
            $null = Import-Module (Import-PSSession @Param) -Scope Global -DisableNameChecking
        }
	}
}