function Format-TitleComponent {
  $title = Write-SpectreHost "[grey42] PowerShell Typer[/]" -PassThru

  $titlePanel = $title | Format-SpectreAligned -HorizontalAlignment Center | Format-SpectrePanel -Border Square -Color grey42

  return $titlePanel
}