<#
.SYNOPSIS
Converts input to a Base64 String. This function is intended to support explicit typing of the input text via an encoding parameter. In most cases UTF8 should be used. However, support for ASCII and Unicode are included for one-way conversions to or from Base64 for sake of usability, if required.

.PARAMETER String
The user-supplied string to convert to Base64.

.PARAMETER Encoding
The explicit encoding of the supplied input. In many cases is not necesarry, but can be useful if working with different character encodings.

.EXAMPLE 
# Convert the string, "Hello, World!" to Base64 while explicitly specifying the supplied text encoding as ASCII
ConvertTo-Base64 -String "Hello World!" -Encoding "ASCII"

.EXAMPLE
# Convert the string "Привіт, світ!" to Base64 while explicitly specifying the supplied text encoding as UTF8. UTF8 is the default switch parameter, so this is not necesarry but is provided for sake of example.
ConvertTo-Base64 -String "Привіт, світ!" -Encoding "UTF8"

.EXAMPLE
# Convert the Base64 string, "0J/RgNC40LLRltGCLCDRgdCy0ZbRgiE=" to UTF8 text while explicitly specifying UTF8 Encoding.
ConvertFrom-Base64 -Base64String "0J/RgNC40LLRltGCLCDRgdCy0ZbRgiE=" -Encoding "UTF8"

.EXAMPLE 
# Convert the Base64 string, "PwRABDgEMgRWBEIEIABBBDIEVgRCBA==" to Unicode text while explicitly specifying Unicode encoding.
ConvertFrom-Base64 -Base64String "PwRABDgEMgRWBEIEIABBBDIEVgRCBA==" -Encoding "Unicode"
#>
function ConvertTo-Base64 {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$String,
    
        [Parameter()]
        [ValidateSet('UTF8', 'ASCII', 'Unicode')]
        [string]$Encoding = 'UTF8'
    )

    process {
        switch ($Encoding) {
            'UTF8'      {$encodebytes = [System.Text.Encoding]::UTF8.GetBytes($String)}
            'ASCII'     {$encodebytes = [System.Text.Encoding]::ASCII.GetBytes($String)}
            'Unicode'   {$encodebytes = [System.Text.Encoding]::Unicode.GetBytes($String)}   
        }
        
        [Convert]::ToBase64String($encodebytes)
        
    }
}

function ConvertFrom-Base64 {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Base64String,

        [Parameter()]
        [ValidateSet('UTF8', 'ASCII', 'Unicode')]
        [string]$Encoding = 'UTF8',

        [Parameter()]
        [Switch]$ErrorOnInvalidInput
    )
    process {
        try {
            $OutputBytes = [Convert]::FromBase64String($Base64String)
            switch ($Encoding) {
                'UTF8'      {[System.Text.Encoding]::UTF8.GetString($OutputBytes)}
                'ASCII'     {[System.Text.Encoding]::ASCII.GetString($OutputBytes)}
                'Unicode'   {[System.Text.Encoding]::Unicode.GetString($OutputBytes)}
            }            
        }
        catch { 
            if ($ErrorOnInvalidInput) {
                throw "Valid input was not provided."
            }
            else {
                Write-Warning "Input is not valid Base64."
            }
        }
    }    
}

Export-ModuleMember -Function ConvertTo-Base64
Export-ModuleMember -Function ConvertFrom-Base64