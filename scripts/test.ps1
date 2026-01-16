$ErrorActionPreference = "Stop"
$ScriptDir = if ($PSScriptRoot) {
  $PSScriptRoot 
} else {
  Get-Location 
}
$UtilsPath = Join-Path $ScriptDir "windows\utils.ps1"
if (-not (Test-Path $UtilsPath)) {
  $UtilsPath = Join-Path $ScriptDir "utils.ps1" 
}
$LinkLib = Join-Path $ScriptDir "windows\link.ps1"
if (Test-Path $LinkLib) { 
  . $LinkLib 
} else { 
  Write-Error "Missing windows\link.ps1"; exit 1 
}
if (Test-Path $UtilsPath) {
  . $UtilsPath 
} else {
  Write-Error "Missing utils.ps1"; exit 1 
}
$SrcPath = "$ScriptDir\.config"
if (-not (Test-Path $SrcPath)) {
  $SrcPath = Resolve-Path "$ScriptDir\..\.config" -ErrorAction SilentlyContinue 
}
if (-not $SrcPath -or -not (Test-Path $SrcPath)) {
  Write-Error "Error: '.config' not found."; exit 1 
}
$Folders = Get-ChildItem -Path $SrcPath -Directory
if ($Folders.Count -eq 0) {
  Write-Warning "No folders found."; exit 
}
$Selected = Show-Menu -Items $Folders -Title "DOTFILES LINKER"
if ($null -eq $Selected) {
  Write-Host "`n>> Cancelled." -F Yellow; exit 
}
if ($Selected.Count -eq 0) {
  Write-Host "`n>> No items selected." -F Yellow; exit 
}
$DestBase = "$HOME\.config"
if (-not (Test-Path $DestBase)) {
  New-Item -Type Directory -Path $DestBase | Out-Null 
}
Write-Host "`n>> Processing $($Selected.Count) items..." -F Cyan
$GlobalState = @{
  OverwriteAll = $false
  SkipAll      = $false
}
foreach ($Item in $Selected) {
  $Target = "$DestBase\$($Item.Name)"
  Link-Item -Src $Item.FullName -Dest $Target -State ([ref]$GlobalState)
}
Write-Host "`nDone." -F Cyan
