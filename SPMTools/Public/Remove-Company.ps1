<#
.SYNOPSIS
Removes a company profile from SPMTools.

.DESCRIPTION
Remove-Company removes the company profile information from disk.
There is no way to recover this information.

.PARAMETER Company
The name of the company to remove.

.EXAMPLE
Removing the company profile for Example Services, LLC.

Remove-Company -Company ExampleServices


.NOTES
Company profiles are stored in %APPDATA%\.SPMTools
Credentials will be removed as well.

#>

Function Remove-Company {
    [cmdletBinding()]
    Param()
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($Script:Config.Companies.Keys)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        if(!$Script:Config.Companes.ContainsKey($PSBoundParameters.Company)) {
            Throw "Company '$Company' does not exist"
        }
    }
    Process {
        Set-Company -Company $Company -RemoveADCredential
        Set-Company -Company $Company -RemoveOnPremCredential
        Set-Company -Company $Company -RemoveOnlineCredential
        $Script:Config.Companies.Remove($Company)
    }
    End {
        Write-SPMTConfiguration
    }
}