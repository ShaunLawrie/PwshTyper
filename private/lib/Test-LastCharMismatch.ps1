function Test-LastCharMismatch {
  param (
    [string] $CurrentInput,
    [string] $Sentence
  )

  $lastChar = $CurrentInput[-1]
  if ($lastChar -ne $Sentence[$CurrentInput.Length - 1]) {
    return $true
  }
}