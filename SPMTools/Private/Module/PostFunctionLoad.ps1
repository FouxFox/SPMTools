#Content here runs after all functions are loaded

$Aliases = @{
    'fs' = 'Format-SortedName'
}

ForEach ($alias in $Aliases.Keys) {
    Set-Alias -Name $alias -Value $Aliases[$alias]
}

Export-ModuleMember -Alias [array]$Aliases.Keys