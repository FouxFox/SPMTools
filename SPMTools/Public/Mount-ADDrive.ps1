<#
.SYNOPSIS
Mounts one or all AD Drives associated with company profiles

.DESCRIPTION
Mount-ADDrive mounts the specified Active Directory drive using the infromation provided in the company profile.
If no company is provided, all companies that have Active Directory information are mounted.

.PARAMETER Company
The company to mount.
If not specified, all applicable companies will be mounted

.PARAMETER Favorites
Mounts companies that are marked as favorites in their configuration

.EXAMPLE
Mount the EX drive for Example Services, LLC

Mount-ADDrive -Company ExampleServices

.EXAMPLE 
Mount all drives

Mount-ADDrive

.NOTES


#>

Function Mount-ADDrive {
    [cmdletBinding()]
    Param(
        [Parameter(
            Mandatory=$false,
            ParameterSetName = 'Favorites')]
        [switch]$Favorites
    )
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.Domain
        }

        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ParameterSetName = 'Company'
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}
    Begin {
        $CompanyName = $PSBoundParameters.Company
    
        if($CompanyName) {
            $CompanyObj = $Script:Config.Companies.$CompanyName
            $DomainObj = $CompanyObj.Domain
            
            New-ADDrive $DomainObj
        }
        elseif ($Favorites) {
            ForEach ($Company in $Script:Config.Companies.Keys) {
                $CompanyObj = $Script:Config.Companies.$Company
                $DomainObj = $CompanyObj.Domain
                
                if($DomainObj.Favorite) {
                    New-ADDrive $DomainObj
                }
            }
        }
        else {
            ForEach ($Company in $Script:Config.Companies.Keys) {
                $CompanyObj = $Script:Config.Companies.$Company
                $DomainObj = $CompanyObj.Domain

                New-ADDrive $DomainObj
            }
        }
    }
}