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