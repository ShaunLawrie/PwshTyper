# TODO: Fix spectre.console so it doesn't break words across multiple lines when they use markup to color each letter individually.
# That's why this mess exists here, it's manually line breaking the sentence data to avoid that issue.
# This function is large and inlined with duplicated code to make it faster.
function Format-SentenceComponent {
  param (
    [string] $Sentence,
    [string] $CurrentInput,
    [int] $AvailableWidth,
    [int] $LeftPadding = 20,
    [int] $RightPadding = 10
  )

  $AvailableWidth -= $LeftPadding + $RightPadding
  
  # Stringbuilder is faster than string concatenation
  $formattedSentence = [System.Text.StringBuilder]::new()
  $inputPosition = 0
  $sentencePosition = 0
  $linePosition = 0
  $rightMargin = 20
  $Sentence = $Sentence | Get-SpectreEscapedText
  $CurrentInput = [string]::IsNullOrEmpty($CurrentInput) ? $CurrentInput : ($CurrentInput | Get-SpectreEscapedText)

  # Process the current input (colored based on correctness)
  for ($inputPosition = 0; $inputPosition -lt $CurrentInput.Length; $inputPosition++) {
    # For the first character on a line we don't want the space
    if ($linePosition -eq 0 -and $CurrentInput[$inputPosition] -eq " ") {
      $sentencePosition++
      continue
    }
    # The current character is either correct or incorrect, we check the current position in the input string against the same position in the sentence string
    if ($CurrentInput[$inputPosition] -ceq $Sentence[$sentencePosition]) {
      $null = $formattedSentence.Append("[green]$($CurrentInput[$inputPosition])[/]")
      $sentencePosition++
    } else {
      $null = $formattedSentence.Append("[red underline]$($CurrentInput[$inputPosition])[/]")
    }
    # Spaces get converted to new lines to avoid the spectre.console issue of breaking words across multiple lines
    if ($linePosition -ge ($AvailableWidth - $rightMargin) -and $CurrentInput[$inputPosition] -eq " ") {
      $null = $formattedSentence.Append("`n")
      $linePosition = 0
    }
    $linePosition++
  }

  # Process the current position
  # Spaces get converted to new lines to avoid the spectre.console issue of breaking words across multiple lines
  $currentChar = $Sentence[$sentencePosition]
  if ($linePosition -ge ($AvailableWidth - $rightMargin) -and $currentChar -eq " ") {
    $null = $formattedSentence.Append("[grey84 on grey19]$currentChar[/]")
    $null = $formattedSentence.Append("`n")
    $linePosition = 0
    $sentencePosition++
    $currentChar = $Sentence[$sentencePosition]
  } else {
    $null = $formattedSentence.Append("[grey84 on grey19]$currentChar[/]")
    $sentencePosition++
  }
  $linePosition++

  # Process the remaining sentence
  $null = $formattedSentence.Append("[grey84]")
  for ($sentencePosition = $sentencePosition; $sentencePosition -lt $Sentence.Length; $sentencePosition++) {
    # For the first character on a line we don't want the space
    if ($linePosition -eq 0 -and $Sentence[$sentencePosition] -eq " ") {
      continue
    }
    # Spaces get converted to new lines to avoid the spectre.console issue of breaking words across multiple lines
    if ($linePosition -ge ($AvailableWidth - $rightMargin) -and $Sentence[$sentencePosition] -eq " ") {
      $null = $formattedSentence.Append("`n")
      $linePosition = 0
    } else {
      $null = $formattedSentence.Append(($Sentence[$sentencePosition]))
    }
    $linePosition++
  }
  $null = $formattedSentence.Append("[/]")

  return $formattedSentence.ToString() | Format-SpectreAligned -HorizontalAlignment Left | Format-SpectrePadded -Top 0 -Left $LeftPadding -Bottom 0 -Right $RightPadding
}