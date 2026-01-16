function Link-Item {
  param (
    [string]$Src,
    [string]$Dest,
    [ref]$State  # Dùng [ref] để lưu lựa chọn "Apply to All" giữa các lần gọi
  )

  $Name = Split-Path $Src -Leaf
  if (-not (Test-Path $Dest)) {
    Write-Host "   [+] Linking: $Name" -F Green
    # TODO: New-Item -ItemType Junction -Path $Dest -Target $Src | Out-Null
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
  if ($State.Value.OverwriteAll) {
    Write-Host "   [!] Overwriting (Auto): $Name" -F Yellow
    # TODO: Rename-Item $Dest "$Dest.bak" -Force
    # TODO: New-Item -ItemType Junction -Path $Dest -Target $Src | Out-Null
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
        # TODO: Rename-Item $Dest "$Dest.bak" -Force
        # TODO: New-Item -ItemType Junction -Path $Dest -Target $Src | Out-Null
        return 
      }
      'S' {
        Write-Host "       -> Skipped." -F DarkGray
        return 
      }
      'A' {
        $State.Value.OverwriteAll = $true
        Write-Host "       -> Replacing All..." -F Yellow
        # TODO: Rename-Item $Dest "$Dest.bak" -Force
        # TODO: New-Item -ItemType Junction -Path $Dest -Target $Src | Out-Null
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
