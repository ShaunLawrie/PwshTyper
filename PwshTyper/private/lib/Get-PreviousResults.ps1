function Get-PreviousResults {
  param (
    [string] $Mode
  )
  if (Test-Path -Path $script:Results) {
    return Get-Content -Path $script:Results | ConvertFrom-Json | Where-Object { $_.Mode -eq $Mode }
  } else {
    return @()
  }
}