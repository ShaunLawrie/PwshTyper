function Format-ResultsComponent {
  param (
    [Spectre.Console.LiveDisplayContext] $Context,
    [Spectre.Console.Layout] $Layout,
    [int] $Mistakes,
    [string] $Completed,
    [string] $Mode,
    [int] $Timeout
  )

  # Display results
  if ([string]::IsNullOrEmpty($Completed)) {
    throw "Completed string is empty" 
  }

  $accuracy = 1 - ($Mistakes / $Completed.Length)
  $wpm = [math]::Round(($Completed.Split(" ").Count) / ($Timeout / 60), 2)
  $resultsData = [ordered]@{
    "Date" = Get-Date
    "Mode" = $Mode
    "Words per Minute" = $wpm
    "Accuracy" = $accuracy
    "Mistakes" = $Mistakes
    "Completed" = $Completed.Split(" ").Count
  }
  $resultsTable = $resultsData | Format-SpectreTable -Title "[grey42]Results`n[/]" -Border Square -Color "white"

  $previousResults = Get-PreviousResults -Mode $Mode
  $resultsChartItems = @($previousResults | Sort-Object -Property Date | Select-Object -Last 4 | ForEach-Object {
    New-SpectreChartItem -Label $_.Date -Value $_."Words per Minute" -Color "#084406"
  })
  $resultsChartItems += New-SpectreChartItem -Label $resultsData.Date -Value $resultsData."Words per Minute" -Color "#11910e"
  $resultsChart = $resultsChartItems | Format-SpectreBarChart -Width ([int]($Host.UI.RawUI.WindowSize.Width / 2))

  $accuracyChartItems = @($previousResults | Sort-Object -Property Date | Select-Object -Last 4 | ForEach-Object {
    New-SpectreChartItem -Label $_.Date -Value ([int]($_.Accuracy * 100)) -Color "#9a3039"
  })
  $accuracyChartItems += New-SpectreChartItem -Label $resultsData.Date -Value ([int]($resultsData.Accuracy * 100)) -Color "#e74856"
  $accuracyChart = $accuracyChartItems | Format-SpectreBarChart -Width ([int]($Host.UI.RawUI.WindowSize.Width / 2))

  $results = @(
    $resultsTable,
    "",
    "[grey42]WPM History[/]",
    "",
    $resultsChart,
    "[grey42]`nAccuracy Percent History[/]",
    "",
    $accuracyChart
  ) | Format-SpectreRows | Format-SpectreAligned -HorizontalAlignment Center

  # Save results
  Set-PreviousResults -Results $resultsData

  $Layout.IsVisible = $true
  $Layout.Update($results) | Out-Null

  $Context.Refresh()
  Start-Sleep -Seconds 3
}