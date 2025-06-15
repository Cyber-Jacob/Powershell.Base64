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
                Write-Warning "Input is not valide Base64."
            }
        }
    }    
}

Export-ModuleMember -Function ConvertTo-Base64
Export-ModuleMember -Function ConvertFrom-Base64