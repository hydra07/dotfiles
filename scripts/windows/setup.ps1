#Link .config subfolders to $HOME\.config on Windows
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
if (Test-Path $UtilsPath) { 
  . $UtilsPath 
} else { 
  Write-Error "Missing utils.ps1"
  return
}
$LinkLib = Join-Path $ScriptDir "windows\link.ps1"
if (-not (Test-Path $LinkLib)) {
  $LinkLib = Join-Path $ScriptDir "link.ps1"
}
if (Test-Path $LinkLib) { 
  . $LinkLib 
} else { 
  Write-Error "Missing link.ps1"
  return
}
$SrcPath = "$ScriptDir\.config"
if (-not (Test-Path $SrcPath)) {
  $SrcPath = Resolve-Path "$ScriptDir\..\..\.config" -ErrorAction SilentlyContinue 
}
if (-not $SrcPath -or -not (Test-Path $SrcPath)) { 
  Write-Error "Error: '.config' directory not found."
  return
}
$Folders = Get-ChildItem -Path $SrcPath -Directory
if ($Folders.Count -eq 0) { 
  Write-Warning "No folders found in .config directory."
  return
}
$Selected = Show-Menu -Items $Folders -Title "DOTFILES LINKER"
if ($null -eq $Selected) { 
  Write-Host "`n>> Cancelled." -ForegroundColor Yellow
  return
}
if ($Selected.Count -eq 0) { 
  Write-Host "`n>> No items selected." -ForegroundColor Yellow
  return
}
$DestBase = "$HOME\.config"
if (-not (Test-Path $DestBase)) {
  New-Item -ItemType Directory -Path $DestBase -Force | Out-Null 
}
Write-Host "`n>> Processing $($Selected.Count) item(s)..." -ForegroundColor Cyan
$GlobalState = @{ 
  OverwriteAll = $false
  SkipAll = $false 
}
foreach ($Item in $Selected) {
  $Target = Join-Path $DestBase $Item.Name
  Link-Item -Src $Item.FullName -Dest $Target -State ([ref]$GlobalState)
  # if neovim Link to %APPDATA%\nvim
  if ($Item.Name -eq "nvim") {
    $NvimDest = Join-Path $env:LOCALAPPDATA "nvim"
    Link-Item -Src $Item.FullName -Dest $NvimDest -State ([ref]$GlobalState)
  }
}
Write-Host "`n>> Linking phase completed." -ForegroundColor Cyan
$Backups = Get-ChildItem -Path $DestBase -Directory -Filter "*.bak" -ErrorAction SilentlyContinue
if ($Backups -and $Backups.Count -gt 0) {
  Write-Host "`n[?] Found $($Backups.Count) backup folder(s) (*.bak):" -ForegroundColor Yellow
  $Backups | ForEach-Object { 
    Write-Host "    - $($_.Name)" -ForegroundColor DarkGray 
  }
  $ChoiceClean = Read-Host "    Do you want to DELETE them to save space? [y/N]"
  if ($ChoiceClean -eq 'y') {
    $Backups | Remove-Item -Recurse -Force
    Write-Host "    [✓] Cleaned up backup files." -ForegroundColor Green
  } else {
    Write-Host "    [!] Kept backup files." -ForegroundColor DarkGray
  }
}
$TargetLine = '. $env:USERPROFILE\.config\powershell\user_profile.ps1'
Write-Host "`n[?] PowerShell Profile Configuration" -ForegroundColor Cyan
if (-not (Test-Path $PROFILE)) {
  $ProfileDir = Split-Path $PROFILE
  if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
  }
  New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
$CurrentContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($CurrentContent -notmatch [regex]::Escape($TargetLine)) {
  Write-Host "    Source script not found in `$PROFILE." -ForegroundColor Yellow
  Write-Host "    Command to add: $TargetLine" -ForegroundColor DarkGray
  $ChoiceProfile = Read-Host "    Add this to your profile? [y/N]"
  if ($ChoiceProfile -eq 'y') {
    Add-Content -Path $PROFILE -Value "`n$TargetLine"
    Write-Host "    [✓] Added successfully! Restart terminal to apply changes." -ForegroundColor Green
  } else {
    Write-Host "    [!] Skipped profile update." -ForegroundColor DarkGray
  }
} else {
  Write-Host "    [✓] Profile is already configured correctly." -ForegroundColor Green
}
Write-Host "`n✓ All operations completed successfully." -ForegroundColor Cyan
