function Get-RandomCommandlets {
  return ((Get-Module Microsoft.PowerShell.Utility).ExportedCmdlets.Keys | Sort-Object { Get-Random }) -join " "
}