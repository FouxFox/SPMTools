Function Format-SortedName ($input) {
    $input | Sort-Object Name | Format-Table Name
}