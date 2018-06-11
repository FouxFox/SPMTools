<#
.SYNOPSIS
Sorts input and displays sorted output in a table

.DESCRIPTION
This cmdlet allows large objects to be quiclky distilled by a single property.
Format-Sorted sorts by Name when -SortOn is not provided.
This cmdlet can also be called with it's alias 'fs'.

.PARAMETER Input
A pipeline input of objects to sort and format

.PARAMETER SortOn
An optional value to use for sorting and output.
Defaults to 'Name' if not provided.

.PARAMETER AutoSize
Runs Format-Table with -AutoSize.

.EXAMPLE
Get-ADGroupMember -Identity 'Domain Admins' | Format-Sorted


.NOTES


#>

Function Format-Sorted {
    [cmdletBinding()]
    [Alias('fs')]
    Param(
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$true
        )]
        $input,

        [Parameter(Mandatory=$false)]
        [string]$SortOn='Name',

        [Parameter(Mandatory=$false)]
        [switch]$AutoSize=$false
    )


    if($input) {
        if($AutoSize) {
            $input | Sort-Object $SortOn | Format-Table $SortOn -AutoSize
        }
        else {
            $input | Sort-Object $SortOn | Format-Table $SortOn
        }
    }
}