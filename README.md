# Powershell.Base64 Module
This Powershell module exists to convert to and from Base64 strings using UTF8, ASCII, and Unicode character encodings. For almost all cases, UTF8 - the default encoding option - should be used. However, the optional Encoding parameter is present for sake of functionality. 

## Usage
``` Powershell

# Convert the string, "Hello, World!" to Base64 while explicitly specifying the supplied text encoding as ASCII.
ConvertTo-Base64String -String "Hello World!" -Encoding "ASCII"

# Convert the string "Привіт, світ!" to Base64 while explicitly specifying the supplied text encoding as UTF8. UTF8 is the default switch parameter, so this is not necesarry but is provided for sake of example.
ConvertTo-Base64String -String "Привіт, світ!" -Encoding "UTF8"

# Convert the Base64 string, "0J/RgNC40LLRltGCLCDRgdCy0ZbRgiE=" to UTF8 text while explicitly specifying UTF8 Encoding.
ConvertFrom-Base64String -Base64String "0J/RgNC40LLRltGCLCDRgdCy0ZbRgiE=" -Encoding "UTF8"

# Convert the Base64 string, "PwRABDgEMgRWBEIEIABBBDIEVgRCBA==" to Unicode text while explicitly specifying Unicode encoding.
ConvertFrom-Base64String -Base64String "PwRABDgEMgRWBEIEIABBBDIEVgRCBA==" -Encoding "Unicode"

# Convert a user-supplied string to Base64 using Read-Host and sending as pipeline-input to a Convert statement.
$string = Read-Host("Enter string to be converted to Base64: ") | ConvertTo-Base64String

# Convert a variable, $string, to Base64 specifying the string encoding as Unicode.
ConvertTo-Base64String -String $string -Encoding "Unicode"

# Convert a Base64 string variable, $string, to cleartext specifying the destination encoding as Unicode.
ConvertFrom-Base64String -String $string -Encoding "Unicode"

```