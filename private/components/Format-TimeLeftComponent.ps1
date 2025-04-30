function Format-TimeLeftComponent {
  param (
    [object] $Start,
    [int] $Timeout
  )

  $TimeLeft = Get-TimeRemaining -Start $Start -Timeout $Timeout
  if ($TimeLeft -lt 0) {
    $TimeLeft = 0
  }

  return "[grey42]$($TimeLeft.ToString("N0")) seconds[/]" | Write-SpectreHost -PassThru | Format-SpectrePadded -Padding 1
}