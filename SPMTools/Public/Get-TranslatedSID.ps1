Function Get-TranslatedSID ($sid) {
	(New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount]).Value
}