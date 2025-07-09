<#
.SYNOPSIS
Converts input to a Base64 String. This function is intended to support explicit typing of the input text via an encoding parameter. In most cases UTF8 should be used. However, support for ASCII and Unicode are included for one-way conversions to or from Base64 for sake of usability, if required.

.EXTERNALHELP "https://github.com/Cyber-Jacob/Powershell.Base64/blob/main/README.md"

.PARAMETER String
The user-supplied string to convert to Base64.

.PARAMETER Encoding
The explicit encoding of the supplied input. In many cases is not necesarry, but can be useful if working with different character encodings.

.EXAMPLE
# Convert the string, "Hello, World!" to Base64 while explicitly specifying the supplied text encoding as ASCII.
ConvertTo-Base64String -String "Hello World!" -Encoding "ASCII"

.EXAMPLE
# Convert the string "Привіт, світ!" to Base64 while explicitly specifying the supplied text encoding as UTF8. UTF8 is the default switch parameter, so this is not necesarry but is provided for sake of example.
ConvertTo-Base64String -String "Привіт, світ!" -Encoding "UTF8"
#>
function ConvertTo-Base64String {
    [CmdletBinding(DefaultParameterSetName='String')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='String', ValueFromPipeline=$true)]
        [string]$String,

        [Parameter(ParameterSetName='String')]
        [ValidateSet('UTF8', 'ASCII', 'Unicode')]
        [string]$Encoding = 'UTF8',

        [Parameter(Mandatory, Position=0, ParameterSetName='File', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PSPath')]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$Path,

        [Parameter(ParameterSetName='File')]
        [string]$OutFile,

        [Parameter(ParameterSetName='File')]
        [switch]$NoLineBreaks       #Insert CRLF every 76 chars per RFC2045; MIME encoded email expects this
    )

    process {
        switch($PSCmdlet.ParameterSetName) {
            
            'String' {
                $encodebytes = switch ($Encoding) {
            'UTF8'      {[System.Text.Encoding]::UTF8.GetBytes($String)}
            'ASCII'     {[System.Text.Encoding]::ASCII.GetBytes($String)}
            'Unicode'   {[System.Text.Encoding]::Unicode.GetBytes($String)}
        }
        [Convert]::ToBase64String($encodebytes)
    }
            'File' {
                $fileitem = Get-Item -LiteralPath $Path
                $bytes = if ($fileitem.length -GT 500MB) {
                    $in = [IO.File]::OpenRead($Path)
                    try {
                        $out = New-Object IO.MemoryStream
                        $cryptostream = New-Object Security.Cryptography.CryptoStream($out, (New-Object Security.Cryptography.ToBase64Transform),[IO.CryptoStreamMode]::Write)
                        $in.CopyTo($cryptostream); $cryptostream.FlushFinalBlock()
                        $out.ToArray()
                    } finally {$in.Dispose(); $cryptostream.Dispose(); $out.Dispose() }
                } else {
                    [IO.File]::ReadAllBytes($Path)
                } 

                $options = if ($NoLineBreaks) {
                    [Convert]::ToBase64String($bytes)
                } else {
                    [Convert]::ToBase64String($bytes,[System.Base64FormattingOptions]::InsertLineBreaks)
                }

                if ($OutFile) { [IO.File]::WriteAllText($OutFile,$options)}
                $options

            }
            
    }
}
}

<#
.SYNOPSIS
Converts input from a Base64 String. This function is intended to support explicit typing of the input text via an encoding parameter. In most cases UTF8 should be used. However, support for ASCII and Unicode are included for one-way conversions to or from Base64 for sake of usability, if required.

.EXTERNALHELP "https://github.com/Cyber-Jacob/Powershell.Base64/blob/main/README.md"

.PARAMETER String
The user-supplied string to convert to Base64.

.PARAMETER Encoding
The explicit encoding of the supplied input. In many cases is not necesarry, but can be useful if working with different character encodings.

.PARAMETER ErrorOnInvalidInput
A switch parameter to throw an error and terminate on user-supplied strings that are not valid Base64 strings.

.EXAMPLE
# Convert the Base64 string, "0J/RgNC40LLRltGCLCDRgdCy0ZbRgiE=" to UTF8 text while explicitly specifying UTF8 Encoding.
ConvertFrom-Base64String -Base64String "0J/RgNC40LLRltGCLCDRgdCy0ZbRgiE=" -Encoding "UTF8"

.EXAMPLE
# Convert the Base64 string, "PwRABDgEMgRWBEIEIABBBDIEVgRCBA==" to Unicode text while explicitly specifying Unicode encoding.
ConvertFrom-Base64String -Base64String "PwRABDgEMgRWBEIEIABBBDIEVgRCBA==" -Encoding "Unicode"
#>

function ConvertFrom-Base64String {
    [CmdletBinding(DefaultParameterSetName='String')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory=$true, Position=0, ParameterSetName='String', ValueFromPipeline=$true)]
        [string]$Base64String,

        [Parameter(ParameterSetName='String')]
        [ValidateSet('UTF8', 'ASCII', 'Unicode')]
        [string]$Encoding = 'UTF8',

        [Parameter(ParameterSetName='String')]
        [Switch]$ErrorOnInvalidInput,

        [Parameter(Mandatory, Position=0, ParameterSetName='File', ValueFromPipelineByPropertyName)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$Path,

        [Parameter(ParameterSetName='String')]
        [Parameter(Mandatory, Position=1, ParametersetName='File')]
        [string]$OutFile,

        [Parameter(ParameterSetName='String')]
        [switch]$PassThru
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'String' {
                try {
                    $OutputBytes = [Convert]::FromBase64String($Base64String)
                } catch {
                    if ($ErrorOnInvalidInput) {
                        throw "Input is not valid Base64."
                    }
                    else {
                        Write-Warning "Input is not valid Base64."
                        return
                    }
                }

                if ($OutFile) { [IO.File]::WriteallBytes($OutFile,$OutputBytes) }

                if ($PassThru) {
                    return ,$OutputBytes
                }
                elseif (-not $OutFile) {
                    switch ($Encoding) {
                        'UTF8'      {[System.Text.Encoding]::UTF8.GetString($OutputBytes)}
                        'ASCII'     {[System.Text.Encoding]::ASCII.GetString($OutputBytes)}
                        'Unicode'   {[System.Text.Encoding]::Unicode.GetString($OutputBytes)}
                    }
                }
                }
            'File'{
                $b64 = Get-Content -LiteralPath $Path -Raw
                try { $bytes = [Convert]::FromBase64String($b64) }
                catch { throw "File does not contain valid Base-64." }
                [IO.file]::WriteAllBytes($OutFile,$bytes)
            }
        }
    }
}


Export-ModuleMember -Function ConvertTo-Base64String,ConvertFrom-Base64String