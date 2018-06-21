Function Get-DellExpressServiceCode {
    [cmdletBinding()]
    Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        [string]$ServiceTag
    )
    Begin {
        $alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
    }
    Process {
        #Set up Variables
        $InputArray = $ServiceTag.ToLower().ToCharArray()
        [array]::Reverse($InputArray)
        [long]$ExpressServiceCodeNum = 0

        #Convert to Decimal
        $pos = 0
        ForEach ($char in $InputArray) {
            $ExpressServiceCodeNum += $alphabet.IndexOf($char) * [long][Math]::Pow(36, $pos)
            $pos++
        }
        
        #Add Dashes
        $ExpressServiceCode = $ExpressServiceCodeNum.ToString() -replace '(...(?!$))','$1-'

        #Print input and output to be nice
        [pscustomobject]@{
            ServiceTag = $ServiceTag
            ExpressServiceCode = $ExpressServiceCode
        }
    }
}