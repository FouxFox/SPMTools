Function New-ADDrive {
    Param(
        $input
    )

    Write-Debug "[New-ADDrive] Started"
    $inputObj = $PSBoundParameters.input
    ForEach ($DomainObj in $inputObj) {
        #First let's make sure a drive doesn't exist
        Write-Debug "[New-ADDrive] Checking if $($DomainObj.PSDriveLetter) exists"
        $DriveExists = $false
        Try {
            Get-PSDrive $DomainObj.PSDriveLetter -ErrorAction Stop
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