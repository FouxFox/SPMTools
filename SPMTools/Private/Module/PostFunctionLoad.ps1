#Content here runs after all functions are loaded

#Load ADs marked as AutoLoad
ForEach ($Company in $Script:Config.Companies.Keys) {
    $CompanyObj = $Script:Config.Companies.$Company
    $DomainObj = $CompanyObj.Domain
    if($DomainObj.AutoConnect) {
        $Param = @{
            Name = $DomainObj.PSDriveLetter
            PSProvider = 'ActiveDirectory'
            Root = ''
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
}


#Set Alises
$Aliases = @{
    'fs' = 'Format-SortedName'
}

ForEach ($alias in $Aliases.Keys) {
    Set-Alias -Name $alias -Value $Aliases[$alias]
}

Export-ModuleMember -Alias [array]$Aliases.Keys