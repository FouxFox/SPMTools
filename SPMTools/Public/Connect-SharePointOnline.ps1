<#
.SYNOPSIS
Connects to Office365's SharePoint Online service.

.DESCRIPTION
Connect-SharePointOnline uses information provided in the profile of the company specified
to connect to SharePoint Online.

.PARAMETER Company
The company profile to use for connecting.
This parameter supports Tab-Completion.

.EXAMPLE
Connect-SharePointOnline -Company ExampleServices


.NOTES


#>

function Connect-SharepointOnline {
	[cmdletbinding()]
    Param()
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.O365
        }

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        $Company = $PSBoundParameters.Company
        $CompanyObj = $Script:Config.Companies.$Company
        $ConnectionCredentials = Get-StoredCredential -Target $CompanyObj.O365.CredentialName

        if($CompanyObj.O365.SharePointUri) {
            $ConnectionURI = $CompanyObj.O365.SharePointUri
        }
        else {
            #Grabs the first part of the user's domain and prays
            $TenantName = $ConnectionCredentials.UserName.Split('@')[1].Split('.')[0]
            $ConnectionURI = "https://$TenantName-admin.sharepoint.com"
        }

        $SPOSession = $false
        if($CompanyObj.O365.Mfa) {
		    $SPOSession = Connect-SPOService -Url $ConnectionURI
        }
        else {
            $SPOSession = Connect-SPOService -Url $ConnectionURI -Credential $ConnectionCredentials
        }

        if($SPOSession) {
            $null = Import-PSSession $SPOSession -AllowClobber -DisableNameChecking
        }
    }
}