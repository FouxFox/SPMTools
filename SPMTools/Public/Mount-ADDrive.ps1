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
    [cmdletBinding(
        DefaultParameterSetName='All',
        SupportsShouldProcess = $true,
        ConfirmImpact='high'
        )]
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

        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ParameterSetName = 'Company'

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        
        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.Domain
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
        Write-Debug "[Mount-ADDrive] Started"
        $CompanyName = $PSBoundParameters.Company

        #Validation Error handling
        if(
            $PSCmdlet.ParameterSetName -eq 'Company' -and (
                !$Script:Config.Companies.ContainsKey($CompanyName) -or
                !$Script:Config.Companies.$CompanyName.Domain
            )
        ) {
            $message = "There is not a company profile available that supports this cmdlet. Please check your configuration and try again."
            $Param = @{
                ExceptionName = "System.ArgumentException"
                ExceptionMessage = $message
                ErrorId = "ExchangeOnlineNoCompaniesAvailable" 
                CallerPSCmdlet = $PSCmdlet
                ErrorCategory = 'InvalidArgument'
            }
            ThrowError @Param
        }

        #Run At Startup
        if($RunAtStartup) {
            if($PSCmdlet.ParameterSetName -eq 'All') {
                $CMD = 'Mount-ADDrive'
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'Favorites') {
                $CMD = 'Mount-ADDrive -Favorites'
            }
            else {
                $CMD = "Mount-ADDrive -Company $CompanyName"
            }

            $SPCaption = "Profile Modification"
            $SPDescriptionMessage = "Adding '{0}' to '{1}'"
            $SPWarningMessage = "This will add '{0}' to your PowerShell Profile. If you need to change this setting in the future, you will need to remove this line from your profile. Are you sure you want to do this?"

            $SPDescription = $SPDescriptionMessage -f $CMD,$Profile
            $SPWarning = $SPWarningMessage -f $CMD
            
            $Answer = $PSCmdlet.ShouldProcess($SPDescription,$SPWarning,$SPCaption)

            if($Answer) {
                $CMD | Out-File -FilePath $profile -Append
            }
        }
        #Actually mounting the drives
        else {
            $DriveInformation = @()

            if($PSBoundParameters.Company) {
                Write-Debug "[Mount-ADDrive] Company parameter specified as $($PSBoundParameters.Company)"
                $CompanyObj = $Script:Config.Companies.$CompanyName
                $DomainObj = $CompanyObj.Domain
                
                Write-Debug "[Mount-ADDrive] Calling New-ADDrive for $Company"
                Try {
                    $DriveInformation += New-ADDrive -InputObj $DomainObj -ErrorAction Stop
                }
                Catch {
                    Write-Warning $_.Exception.Message
                }
            }
            elseif ($Favorites) {
                Write-Debug "[Mount-ADDrive] Favorites paramters specified"
                ForEach ($Company in $Script:Config.Companies.Keys) {
                    Write-Debug "[Mount-ADDrive] Checking company $Company"
                    $CompanyObj = $Script:Config.Companies.$Company
                    $DomainObj = $CompanyObj.Domain
                    
                    if($DomainObj -and $DomainObj.Favorite) {
                        Write-Debug "[Mount-ADDrive] Calling New-ADDrive for $Company"
                        Try {
                            $DriveInformation += New-ADDrive -InputObj $DomainObj -ErrorAction Stop
                        }
                        Catch {
                            Write-Warning $_.Exception.Message
                        }
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
                        Try {
                            $DriveInformation += New-ADDrive -InputObj $DomainObj -ErrorAction Stop
                        }
                        Catch {
                            Write-Warning $_.Exception.Message
                        }
                    }
                }
            }

            Write-Debug "[Mount-ADDrive] Printing drive info"
            #Need to wirte a type for this
            $DriveInformation | Format-Table -AutoSize Name,Server
        }
    }
}