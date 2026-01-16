function Link-Item {
  param (
    [string]$Src,
    [string]$Dest,
    [ref]$State
  )
  $Name = Split-Path $Src -Leaf
  if (-not (Test-Path $Dest)) {
    Write-Host "   [+] Linking: $Name" -F Green
    New-Item -ItemType Junction -Path $Dest -Value $Src | Out-Null
    return
  }
  $ExistingTarget = ""
  try {
    $ExistingTarget = (Get-Item $Dest).Target 
  } catch {
  }
  if ($ExistingTarget -eq $Src) {
    Write-Host "   [=] Skipped (Already linked): $Name" -F DarkGray
    return
  }
  $ActionReplace = {
    $BackupPath = "$Dest.bak"
    if (Test-Path $BackupPath) {
      Remove-Item -Path $BackupPath -Recurse -Force 
    }
    Rename-Item -Path $Dest -NewName "$($Name).bak" -Force
    New-Item -ItemType Junction -Path $Dest -Value $Src | Out-Null
  }
  if ($State.Value.OverwriteAll) {
    Write-Host "   [!] Overwriting (Auto): $Name" -F Yellow
    & $ActionReplace 
    return
  }
  if ($State.Value.SkipAll) {
    Write-Host "   [-] Skipping (Auto): $Name" -F DarkGray
    return
  }
  Write-Host "   [?] Conflict: '$Name' exists at destination." -F Red
  while ($true) {
    $Choice = Read-Host "       Action? [R]eplace / [S]kip / [A]ll Replace / [N]one (Skip All)"
    switch ($Choice.ToUpper()) {
      'R' {
        Write-Host "       -> Replacing..." -F Yellow
        & $ActionReplace 
        return 
      }
      'S' {
        Write-Host "       -> Skipped." -F DarkGray
        return 
      }
      'A' {
        $State.Value.OverwriteAll = $true
        Write-Host "       -> Replacing All..." -F Yellow
        & $ActionReplace 
        return
      }
      'N' {
        $State.Value.SkipAll = $true
        Write-Host "       -> Skipping All..." -F DarkGray
        return
      }
    }
  }
}
