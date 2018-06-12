Function New-ADDrive {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [Hashtable[]]$input
    )

    ForEach ($DomainObj in $input) {
        #First let's make sure a drive doesn't exist
        $DriveExists = $false
        Try {
            Get-PSDrive $DomainObj.PSDriveLetter -ErrorAction Stop
            $DriveExists = $true
        } 
        Catch { }

        if(!$DriveExists) {
            $Param = @{
                Name = $DomainObj.PSDriveLetter
                PSProvider = 'ActiveDirectory'
                Root = ''
                Scope = 'Global'
            }
            
            if($DomainObj.PreferedDomainController) {
                $Param.Add('Server',$DomainObj.PreferedDomainController)
            }
            else {
                $Param.Add('Server',$DomainObj.FQDN)
            }

            if($DomainObj.CredentialName) {
                $ConnectionCredentials = Get-StoredCredential -Target $DomainObj.CredentialName		
                $Param.Add("Credential",$ConnectionCredentials)
            }		
            
            New-PSDrive @Param
        }
        else {
            Throw "The drive '$($DomainObj.PSDriveLetter)' exists. Please unmount it before calling Import-ADDrive again"
        }
    }
}