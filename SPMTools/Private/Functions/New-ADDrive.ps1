Function New-ADDrive {
    Param(
        $InputObj
    )

    Write-Debug "[New-ADDrive] Started"
    $inputObj = $PSBoundParameters.InputObj

    Write-Debug "[New-ADDrive] Checking for ActiveDirectory PSProvider"
    Try {
        $null = Get-PSProvider -PSProvider ActiveDirectory -ErrorAction Stop
        Write-Debug "[New-ADDrive] PSProvider Found"
    }
    Catch [System.Management.Automation.ProviderNotFoundException] {
        Write-Debug "[New-ADDrive] PSProvider Missing"
        $ADPS_LoadDriveState = $false
        
        if(
            $Env:ADPS_LoadDefaultDrive -eq 1 -or
            $Env:ADPS_LoadDefaultDrive -eq $null
        ) {
            #Save old value if needed.
            #If the value is not set, the module sets it to '1' on startup
            Write-Debug "[New-ADDrive] LoadDefaultDrive set to TRUE"
            $ADPS_LoadDriveState = 1
            $Env:ADPS_LoadDefaultDrive = 0
        }

        #The ActiveDirectory PSProvider can go missing after it's imported.
        #Thus we refrest to be sure 
        Write-Debug "[New-ADDrive] Removing and re-adding ActiveDirectory"
        Remove-Module ActiveDirectory -Force -ErrorAction SilentlyContinue
        Import-Module ActiveDirectory -ErrorAction Stop

        #Reset value back to defaults
        if($ADPS_LoadDriveState -eq 1) {
            Write-Debug "[New-ADDrive] Restoring LoadDefaultDrive state"
            $Env:ADPS_LoadDefaultDrive = $ADPS_LoadDriveState
        }
    }

    ForEach ($DomainObj in $inputObj) {
        #First let's make sure a drive doesn't exist
        Write-Debug "[New-ADDrive] Checking if $($DomainObj.PSDriveLetter) exists"
        $DriveExists = $false
        Try {
            $null = Get-PSDrive -Name $DomainObj.PSDriveLetter -ErrorAction Stop
            $DriveExists = $true
            Write-Debug "[New-ADDrive] Drive exists"
        } 
        Catch { 
            Write-Debug "[New-ADDrive] Drive does not exist"
        }

        if(!$DriveExists) {
            Write-Debug "[New-ADDrive] Creating drive"
            $Param = @{
                Name = $DomainObj.PSDriveLetter
                PSProvider = 'ActiveDirectory'
                Root = ''
                Scope = 'Global'
            }
            
            if($DomainObj.PreferedDomainController) {
                Write-Debug "[New-ADDrive] Using Prefered Domain Controller $($DomainObj.PreferedDomainController)"
                $Param.Add('Server',$DomainObj.PreferedDomainController)
            }
            else {
                Write-Debug "[New-ADDrive] Using FQDN"
                $Param.Add('Server',$DomainObj.FQDN)
            }

            if($DomainObj.CredentialName) {
                Write-Debug "[New-ADDrive] Credentials found. Using $($DomainObj.CredentialName)"
                $ConnectionCredentials = Get-StoredCredential -Target $DomainObj.CredentialName		
                $Param.Add("Credential",$ConnectionCredentials)
            }		
            
            Write-Debug "[New-ADDrive] Calling New-PSDrive"
            New-PSDrive @Param
        }
        else {
            Throw "The drive '$($DomainObj.PSDriveLetter)' exists. Please unmount it before calling Import-ADDrive again"
        }
    }
}