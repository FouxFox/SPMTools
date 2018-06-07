Function Get-NamedStoredCredential {
	[cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Target,
        [Parameter(Mandatory=$true)]
        [string]$TargetName
    )
	
	$ConnectionCredentials = Get-StoredCredential -Target $Target

	if(!$ConnectionCredentials -or $NewCredential) {
		$ConnectionCredentials = Get-Credential -Message "Enter Credentials for $TargetName. Credentials will be saved"
		$Param = @{
			Target = "$Target" 
			Persist = "Enterprise" 
			Credentials = $ConnectionCredentials
		}
		$null = New-StoredCredential @Param
		
	}
	return $ConnectionCredentials
}