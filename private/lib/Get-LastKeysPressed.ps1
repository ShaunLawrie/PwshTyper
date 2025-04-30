function Get-LastKeysPressed {
  if ([Console]::KeyAvailable) {
    $keys = @()
    while ([Console]::KeyAvailable) {
      $keys += [Console]::ReadKey($true)
    }
    return $keys
  }
}