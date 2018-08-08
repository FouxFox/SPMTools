<#
.SYNOPSIS
Sorts input and displays sorted output in a table

.DESCRIPTION
This cmdlet allows large objects to be quiclky distilled by a single property.
Format-Sorted sorts by Name when -SortOn is not provided.
This cmdlet can also be called with it's alias 'fs'.

.PARAMETER Input
Specifies the objects to sort and Format.

When you use the Input parameter to submit a collection of items, Format-Sorted receives one object that represents the collection. Because one object cannot be sorted, Format-Sorted returns the entire collection unchanged.

To sort objects, pipe them to Format-Sorted.

.PARAMETER SortOn
Specifies the properties to use when sorting. Objects are sorted based on the values of these properties. Enter the names of the properties. Wildcards are permitted.

If you specify multiple properties, the objects are first sorted by the first property. If more than one object has the same value for the first property, those objects are sorted by the second property. This process continues
until there are no more specified properties or no groups of objects.

If you do not specify properties, the cmdlet sorts based on default properties for the object type.

The value of the Property parameter can be a calculated property. To create a calculated, property, use a hash table. Valid keys are:

- Expression <string> or <script block>

- Ascending <Boolean>

- Descending <Boolean>

.PARAMETER AutoSize
Runs Format-Table with -AutoSize.

.PARAMETER Descending
Indicates that the cmdlet sorts the objects in descending order. The default is ascending order.

The Descending parameter applies to all properties. To sort by some properties in ascending order and others in descending order, you must specify their property values by using a hash table.

.PARAMETER GroupBy
Specifies sorted output in separate tables based on a property value. For example, you can use GroupBy to list services in separate tables based on their status.

Enter an expression or a property of the output. The output must be sorted before you send it to Format-Table .

The value of the GroupBy parameter can be a new calculated property. To create a calculated, property, use a hash table. Valid keys are:

- Name (or Label) <string>

- Expression <string> or <script block>

- FormatString <string>

.PARAMETER CaseSensitive
Indicates that the sort should be case sensitive. By default, sorting is not case sensitive.

.PARAMETER Culture
Specifies the cultural configuration to use when sorting.

.PARAMETER Unique
Indicates that the cmdlet eliminates duplicates and returns only the unique members of the collection. You can use this parameter instead of using the Get-Unique cmdlet.

This parameter is case-insensitive. As a result, strings that differ only in character casing are considered to be the same.

.EXAMPLE
Get-ADGroupMember -Identity 'Domain Admins' | Format-Sorted


.NOTES


#>

Function Format-Sorted {
    [cmdletBinding(DefaultParameterSetName='All')]
    [Alias('fs')]
    Param(
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$true
        )]
        [PSObject]$Input,

        [Parameter(
            Mandatory=$false,
            ParameterSetName='SortOn'
        )]
        [Object[]]$SortOn='Name',

        #Sort-Object Parameters
        [Parameter(Mandatory=$false)]
        [Switch]$CaseSensitive=$false,

        [Parameter(Mandatory=$false)]
        [string]$Culture,

        [Parameter(Mandatory=$false)]
        [Switch]$Descending=$false,

        [Parameter(Mandatory=$false)]
        [Switch]$Unique=$false,

        #Format-Table Parameters
        [Parameter(
            Mandatory=$false,
            Position=1
        )]
        [Object[]]$Property=$null,

        [Parameter(Mandatory=$false)]
        [switch]$AutoSize=$false,

        [Parameter(
            Mandatory=$false,
            ParameterSetName='GroupBy'
        )]
        [Object]$GroupBy,

        [Parameter(Mandatory=$false)]
        [switch]$HideTableHeaders=$false
    )


    if($input) {
        #Logic
        if($GroupBy) {
            $SortOn = $GroupBy
        }
        if($null -eq $Property -and $SortOn.GetType().Name -ne "HashTable") {
            $Property = $SortOn
        }

        #Params for Sort-Object
        $SOParam = @{
            Property = $SortOn
            CaseSensitive = $CaseSensitive
            Descending = $Descending
            Unique = $Unique
        }
        if($Culture) {
            $SOParam.Add('Culture',$Culture)
        }

        #Params for Filter Table
        $FTParam = @{
            Property = $Property
            AutoSize = $AutoSize
            HideTableHeaders = $HideTableHeaders
        }
        if($GroupBy) {
            $FTParam.Add('GroupBy',$GroupBy)
        }
        if($GroupBy) {
            $FTParam.Add('View',$View)
        }

        #Run
        $input | Sort-Object @SOParam | Format-Table @FTParam
    }
}