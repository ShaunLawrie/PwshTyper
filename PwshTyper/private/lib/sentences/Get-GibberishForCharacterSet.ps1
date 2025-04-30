function Get-GibberishForCharacterSet {
  param (
    [array] $CharacterSet,
    [int] $Length
  )

  $characters = 0
  $words = 0
  $sentence = ""
  $stopChars = @(".", ",", "?", "!")
  $nextWordAtCharacter = 3 + (Get-Random 8)
  while ($words -lt $Length) {
    $sentence += $CharacterSet | Get-Random
    $characters++
    # Add a space every 3 to 10 characters or if the character is ", . ? !"
    if (($stopChars -contains $sentence[-1]) -or $characters -eq $nextWordAtCharacter) {
      $sentence += " "
      $words++
      $characters = 0
      $nextWordAtCharacter = 3 + (Get-Random 8)
    }
  }
  return $sentence.Trim()
}