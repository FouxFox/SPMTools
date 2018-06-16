<#
.SYNOPSIS
Removes a company profile from SPMTools.

.DESCRIPTION
Remove-Company removes the company profile information from disk.
There is no way to recover this information.

.PARAMETER Name
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
        $ParameterName = 'Name'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ValueFromPipeline = $true

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)

        $ValidateSet = $Script:Config.Companies.Keys
        if($ValidateSet.length -gt 0) {
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)
            $AttributeCollection.Add($ValidateSetAttribute)
        }
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        $CompanyName = $PSBoundParameters.Name
        #Validation Error handling
        if(!$Script:Config.Companies.ContainsKey($CompanyName)) {
            $message = "No companies have been set up. Please use the New-Company command to create one."
            $Param = @{
                ExceptionName = "System.ArgumentException"
                ExceptionMessage = $message
                ErrorId = "RemoveCompanyNoCompaniesAvailable" 
                CallerPSCmdlet = $PSCmdlet
                ErrorCategory = 'InvalidArgument'
            }
            ThrowError @Param
        }
    }
    Process {
        Set-Company -Name $CompanyName -RemoveADCredential
        Set-Company -Name $CompanyName -RemoveOnPremCredential
        Set-Company -Name $CompanyName -RemoveOnlineCredential
        $Script:Config.Companies.Remove($CompanyName)
    }
    End {
        Write-SPMTConfiguration
    }
}