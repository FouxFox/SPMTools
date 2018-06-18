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

.PARAMETER RunAtStartup
If specified, Mount-ADDrive will append 

.EXAMPLE
Mount the EX drive for Example Services, LLC

Mount-ADDrive -Company ExampleServices

.EXAMPLE 
Mount all drives

Mount-ADDrive

.NOTES


#>

Function Mount-ADDrive {
    [cmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(
            Mandatory=$false,
            ParameterSetName='Favorites'
        )]
        [switch]$Favorites,

        [Parameter(Mandatory=$false)]
        [switch]$RunAtStartup

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
        Write-Debug "[Mount-ADDrive] Started"

        if($RunAtStartup) {
            if($PSCmdlet.ParameterSetName -eq 'All') {
                $CMD = 'Mount-ADDrive'
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'Favorites') {
                $CMD = 'Mount-ADDrive -Favorites'
            }
            else {
                $CMD = "Mount-ADDrive -Company $Company"
            }

            $SCCaption = "Profile Modification"
            $RunAtStartupMessage = "This will add '{0}' to your PowerShell Profile. If you need to change this setting in the future, you will need to remove this line from your profile. Are you sure you want to do this?"

            $SCMessage = $RunAtStartupMessage -f $CMD
            
            $Answer = $PSCmdlet.ShouldContinue($SCMessage,$SCCaption,$true,[ref]$false,[ref]$false)

            if($Answer) {
                $CMD | Out-File -FilePath $profile -Append
            }
        }
        else {
            $DriveInformation = @()

            if($PSBoundParameters.Company) {
                Write-Debug "[Mount-ADDrive] Company parameter specified as $($PSBoundParameters.Company)"
                $CompanyName = $PSBoundParameters.Company
                $CompanyObj = $Script:Config.Companies.$CompanyName
                $DomainObj = $CompanyObj.Domain
                
                Write-Debug "[Mount-ADDrive] Calling New-ADDrive"
                $DriveInformation += New-ADDrive -InputObj $DomainObj
            }
            elseif ($Favorites) {
                Write-Debug "[Mount-ADDrive] Favorites paramters specified"
                ForEach ($Company in $Script:Config.Companies.Keys) {
                    Write-Debug "[Mount-ADDrive] Checking company $Company"
                    $CompanyObj = $Script:Config.Companies.$Company
                    $DomainObj = $CompanyObj.Domain
                    
                    if($DomainObj -and $DomainObj.Favorite) {
                        Write-Debug "[Mount-ADDrive] Calling New-ADDrive for $Company"
                        $DriveInformation += New-ADDrive -InputObj $DomainObj
                    }
                }
                if($DriveInformation.count -eq 0) {
                    Write-Warning 'No Companies marked as favorite.'
                }
            }
            else {
                Write-Debug "[Mount-ADDrive] No paramter specified"
                ForEach ($Company in $Script:Config.Companies.Keys) {
                    Write-Debug "[Mount-ADDrive] Checking company $Company"
                    $CompanyObj = $Script:Config.Companies.$Company
                    $DomainObj = $CompanyObj.Domain
                    
                    if($DomainObj) {
                        Write-Debug "[Mount-ADDrive] Calling New-ADDrive for $Company"
                        $DriveInformation += New-ADDrive -InputObj $DomainObj
                    }
                }
            }

            Write-Debug "[Mount-ADDrive] Printing drive info"
            #This command can sometimes output both ADDriveInfo Objects AND
            #ProviderInfo objects. This filter stops that.
            #It's also nice to show the user what they're connected to.
            $Filter = { $_.GetType().Name -eq 'ADDriveInfo' }
            $DriveInformation | Where-Object $Filter | Format-Table -AutoSize Name,Server
        }
    }
}