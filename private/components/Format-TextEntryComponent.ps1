function Format-TextEntryComponent {
  param (
    [Spectre.Console.LiveDisplayContext] $Context,
    [Spectre.Console.Layout] $RootLayout,
    [string] $TargetLayoutName,
    [string] $Sentence,
    [string] $CurrentInput,
    [int] $Timeout,
    [object] $Start
  )

  $layoutSizes = Get-SpectreLayoutSizes -Layout $RootLayout
  $targetLayoutSize = $layoutSizes[$TargetLayoutName].Width
  $targetLayout = $RootLayout[$TargetLayoutName]

  $timeLeftPanel = Format-TimeLeftComponent -Start $Start -Timeout $Timeout
  $sentencePanel = Format-SentenceComponent -Sentence $Sentence -CurrentInput $CurrentInput -AvailableWidth $targetLayoutSize

  $newLayoutData = @(
    $timeLeftPanel,
    $sentencePanel
  ) | Format-SpectreRows -Expand | Format-SpectreAligned -VerticalAlignment Middle | Format-SpectrePanel -Border None -Expand

  $targetLayout.Update($newLayoutData) | Out-Null

  $Context.Refresh()
}
