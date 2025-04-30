function Invoke-PwshTyper {
  [CmdletBinding()]
  param (
    # The mode to run e.g. Pinky, Ring, Middle, Index, or one of the wordlists in ../wordlists
    [string] $Mode,
    # The duration in seconds to run the test for
    [int] $Duration,
    # Whether to include punctuation in the test e.g. country name! and city name? (only applies to wordlists)
    [bool] $Punctuation,
    # Whether to use title case in the test e.g. Country Name and City Name (only applies to wordlists)
    [bool] $TitleCase
  )
  
  $ErrorActionPreference = "Stop"

  # Read the files in $PSScriptRoot/../wordlists
  $wordModes = Get-ChildItem -Path "$PSScriptRoot/../wordlists" -Filter "*.txt" -Recurse | ForEach-Object {
    $firstChar = $_.BaseName[0].ToString().ToUpper()
    $endOfWord = $_.BaseName.Substring(1)
    return "$firstChar$endOfWord"
  }

  # Read the default settings file
  $settingsFile = "$PSScriptRoot/../settings.json"
  if (Test-Path -Path $settingsFile) {
    $settings = Get-Content -Path $settingsFile | ConvertFrom-Json
  } else {
    $settings = @{
      Punctuation = "y"
      TitleCase = "y"
      Duration = 60
    }
  }

  # Setup
  $choices = @{
    "Word Modes" = @($wordModes)
    "Finger Modes" = @(
      "Pinky",
      "Ring",
      "Middle",
      "Index"
    )
  }

  if (!$PSBoundParameters.ContainsKey("Mode")) {
    $Mode = Read-SpectreSelectionGrouped -Message "Select a paragraph generator mode..." -PageSize 100 -Choices $choices
  }
  Write-SpectreHost "[grey42]Mode:[/] $Mode"

  if (!$PSBoundParameters.ContainsKey("Punctuation")) {
    $Punctuation = Read-SpectreConfirm -Message "Do you want to include punctuation?" -DefaultAnswer $settings.Punctuation
    if ($Punctuation) {
      $settings.Punctuation = "y"
    } else {
      $settings.Punctuation = "n"
    }
  }
  Write-SpectreHost "[grey42]Punctuation:[/] $Punctuation"

  if (!$PSBoundParameters.ContainsKey("TitleCase")) {
    $TitleCase = Read-SpectreConfirm -Message "Do you want to use title case?" -DefaultAnswer $settings.TitleCase
  if ($TitleCase) {
      $settings.TitleCase = "y"
    } else {
      $settings.TitleCase = "n"
    }
  }
  Write-SpectreHost "[grey42]TitleCase:[/] $TitleCase"

  if (!$PSBoundParameters.ContainsKey("Duration")) {
    $settings.Duration = Read-SpectreText -Prompt "Enter the duration in seconds: " -DefaultAnswer $settings.Duration
    $Duration = $settings.Duration
  }
  Write-SpectreHost "[grey42]Duration:[/] $Duration seconds"

  # Update the default settings file with the new values
  $settingsJson = $settings | ConvertTo-Json -Depth 5
  $settingsJson | Out-File -FilePath $settingsFile -Force

  # Layout
  $layout = New-SpectreLayout -Name "root" -Rows @(
    # Row 1
    (New-SpectreLayout -Name "title" -MinimumSize 8 -Ratio 1 -Data (Format-TitleComponent)),
    # Row 2
    (New-SpectreLayout -Name "main" -Ratio 100 -Data ("empty")),
    # Row 3
    (New-SpectreLayout -Name "results" -Ratio 200 -Data ("empty"))
  )
  $layout["results"].IsVisible = $false

  # Main loop
  Invoke-SpectreLive -Data $layout -ScriptBlock {
    param (
      [Spectre.Console.LiveDisplayContext] $Context
    )

    # Data
    $start = $null
    $current = ""
    $mistakes = 0
    $allowedKeys = $script:KeyMappings.Pinky + $script:KeyMappings.Ring + $script:KeyMappings.Middle + $script:KeyMappings.Index + $script:KeyMappings.Thumb
    $sentence = switch ($Mode) {
      "Pinky" { Get-PinkyOnlySentence }
      "Ring" { Get-RingFingerOnlySentence }
      "Middle" { Get-MiddleFingerOnlySentence }
      "Index" { Get-IndexFingerOnlySentence }
      default { Get-RandomWordlist -Path "$PSScriptRoot/../wordlists/$Mode.txt" -Punctuation $Punctuation -TitleCase $TitleCase -AllowedKeys $allowedKeys }
    }

    while ($true) {
      # Render TUI components
      Format-TextEntryComponent -Context $Context -RootLayout $layout -TargetLayoutName "main" -Sentence $sentence -CurrentInput $current -Timeout $Duration -Start $start

      # Handle input
      $lastKeysPressed = Get-LastKeysPressed

      foreach ($key in $lastKeysPressed) {
        if ($key.Key -eq "C" -and $key.Modifiers -eq "Control") {
          return
        } elseif ($key.Key -eq "Backspace" -and $current.Length -gt 0) {
          # Remove the last character from the current string
          $current = $current.Substring(0, $current.Length - 1)
        } elseif ($allowedKeys -notcontains $key.KeyChar) {
          # Ignore some keys
        } else {
          # Start the timer on the first key press
          if ($null -eq $start) {
            $start = Get-Date
          }
    
          # Add the last key pressed to the current string
          $current += $key.KeyChar
          
          # Check for mistakes
          if (Test-LastCharMismatch -CurrentInput $current -Sentence $sentence) {
            $mistakes++
          }
        }
      }

      if ((Get-TimeRemaining -Start $start -Timeout $Duration) -lt 0) {
        break
      }
    }

    # Render the results component
    Format-ResultsComponent -Context $Context -Layout $layout["results"] -Mistakes $mistakes -Completed $current -Mode $Mode -Timeout $Duration
  }
}