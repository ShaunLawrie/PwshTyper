function Get-TimeRemaining {
  param (
    [object] $Start,
    [int] $Timeout
  )
  $TimeLeft = $Timeout
  if ($Start -is [datetime]) {
    $TimeLeft = $Timeout - ((Get-Date) - $Start).TotalSeconds
  }
  return $TimeLeft
}