function Get-RandomWordlist {
  param (
    [Parameter(Mandatory)]
    [string] $Path,
    [Parameter(Mandatory)]
    [string[]] $AllowedKeys,
    [bool] $Punctuation = $false,
    [bool] $TitleCase = $false
  )

  $words = Get-Content -Path $Path | Sort-Object { Get-Random }
  # Remove unwanted characters from the words (using allowedkeys)
  # Combine all allowed keys into a regex pattern
  $allowedKeysEscaped = (($AllowedKeys | Foreach-Object { [regex]::Escape($_) -replace '\]', '\]' }) -join "")
  $adjustedWords = $words | ForEach-Object {
    $word = $_ -replace "[^$allowedKeysEscaped]", ""
    if ($word -ne $_) {
      Write-Warning "Removed characters from word: $word, check the wordlist for words that contain characters not available in `$script:KeyMappings"
    }
    return $word
  }
  if (Compare-Object -ReferenceObject $words -DifferenceObject $adjustedWords) {
    Write-Warning "Modified words to only include allowed keys, check the wordlist for words that contain characters not available in `$script:KeyMappings"
    Start-Sleep -Seconds 10
  }

  # Every 5 to 15 words add a period, comma, or question mark then make the next word start with a capital letter
  $sentence = ""
  $wordCount = 0
  $nextSentence = Get-Random -Minimum 5 -Maximum 15
  $stopChars = @(".", ",", "?", "!")
  foreach ($word in $words) {

    if ($TitleCase) {
      $lastChar = $sentence.Trim()[-1]
      if ($null -eq $lastChar -or ($lastChar -ne "," -and $stopChars -contains $lastChar)) {
        $word = $word.Substring(0, 1).ToUpper() + $word.Substring(1)
      }
    }
    
    $sentence += $word
    $wordCount++

    if ($wordCount -eq $nextSentence -and $Punctuation) {
      $sentence += $stopChars | Get-Random
      $sentence += " "
      $nextSentence = $wordCount + (Get-Random -Minimum 5 -Maximum 15)
      $wordCount = 0
    } else {
      $sentence += " "
    }
  }

  return $sentence.Trim()
}