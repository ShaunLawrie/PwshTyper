[Console]::TreatControlCAsInput = $true

$script:Results = "$PSScriptRoot\results.json"
$script:KeyMappings = @{
  Pinky = @("q", "a", "z", "p", "Q", "A", "Z", "P", ";", ":", "/", "?", "[", "{", "'", '"', "}", "]", "\", "|", "1", "!", "``", "~", "0", ")", "-", "_", "=", "+")
  Ring = @("w", "s", "x", "o", "l", "W", "S", "X", "O", "L", "2", "@", ".", ">", "9", "(")
  Middle = @("e", "d", "c", "i", "k", "E", "D", "C", "I", "K", "3", "#", ",", "<", "8", "*")
  Index = @("r", "t", "f", "g", "v", "b", "R", "T", "F", "G", "V", "B", "y", "h", "n", "u", "j", "m", "Y", "H", "N", "U", "J", "M", "4", "$", "5", "%", "6", "^", "7", "&")
  Thumb = @(" ")
}

# Import all lib functions and UI components
Get-ChildItem -Path "$PSScriptRoot\private" -Filter "*.ps1" -Recurse | ForEach-Object {
  . $_.FullName
}

# Import module functions
Get-ChildItem -Path "$PSScriptRoot\public" -Filter "*.ps1" -Recurse | ForEach-Object {
  . $_.FullName
}