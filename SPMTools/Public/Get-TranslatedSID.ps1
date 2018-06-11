<#
.SYNOPSIS
Translates a SID to a username.

.DESCRIPTION
This command provides a shortcut to translate a SID to an NT Account name.

.PARAMETER SID
The SID to translate.

.EXAMPLE
PS C:\> Get-TranslatedSID -sid S-1-5-7
NT AUTHORITY\ANONYMOUS LOGON

.NOTES


#>

Function Get-TranslatedSID ($sid) {
	$SIDObj = New-Object System.Security.Principal.SecurityIdentifier($sid)
	$SIDObj.Translate([System.Security.Principal.NTAccount]).Value
}