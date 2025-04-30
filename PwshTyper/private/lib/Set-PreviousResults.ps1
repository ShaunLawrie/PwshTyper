function Set-PreviousResults {
  param (
    [object] $Results
  )

  $previousResults = @()
  if (Test-Path -Path $script:Results) {
    $previousResults = Get-Content -Path $script:Results | ConvertFrom-Json
  }
  @($previousResults) + $resultsData | ConvertTo-Json | Set-Content -Path $script:Results
}