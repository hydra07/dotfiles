function Link-Item {
  param (
    [string]$Src,
    [string]$Dest,
    [ref]$State
  )
  $Name = Split-Path $Src -Leaf
  if (-not (Test-Path $Dest)) {
    Write-Host "   [+] Linking: $Name" -F Green
    # [ACTION] Tạo Junction (Link) trỏ từ Dest về Src
    New-Item -ItemType Junction -Path $Dest -Value $Src | Out-Null
    return
  }
  # --- CASE 2: Đích đã tồn tại -> Kiểm tra ---
  $ExistingTarget = ""
  try {
    $ExistingTarget = (Get-Item $Dest).Target 
  } catch {
  }
  # Nếu đã là Link và trỏ đúng chỗ -> Skip
  if ($ExistingTarget -eq $Src) {
    Write-Host "   [=] Skipped (Already linked): $Name" -F DarkGray
    return
  }
  # --- CASE 3: CONFLICT -> Cần xử lý Backup & Link ---
  $ActionReplace = {
    # 1. Xóa file backup cũ nếu đã tồn tại (.config/nvim.bak)
    $BackupPath = "$Dest.bak"
    if (Test-Path $BackupPath) {
      Remove-Item -Path $BackupPath -Recurse -Force 
    }
    # 2. Đổi tên folder hiện tại thành .bak (Backup)
    Rename-Item -Path $Dest -NewName "$($Name).bak" -Force
    # 3. Tạo Link mới (Junction)
    New-Item -ItemType Junction -Path $Dest -Value $Src | Out-Null
  }
  # 3a. Auto Overwrite
  if ($State.Value.OverwriteAll) {
    Write-Host "   [!] Overwriting (Auto): $Name" -F Yellow
    & $ActionReplace # Thực thi Action
    return
  }
  # 3b. Auto Skip
  if ($State.Value.SkipAll) {
    Write-Host "   [-] Skipping (Auto): $Name" -F DarkGray
    return
  }
  # 3c. Hỏi User
  Write-Host "   [?] Conflict: '$Name' exists at destination." -F Red
  while ($true) {
    $Choice = Read-Host "       Action? [R]eplace / [S]kip / [A]ll Replace / [N]one (Skip All)"
    switch ($Choice.ToUpper()) {
      'R' {
        Write-Host "       -> Replacing..." -F Yellow
        & $ActionReplace # Thực thi Action
        return 
      }
      'S' {
        Write-Host "       -> Skipped." -F DarkGray
        return 
      }
      'A' {
        $State.Value.OverwriteAll = $true
        Write-Host "       -> Replacing All..." -F Yellow
        & $ActionReplace # Thực thi Action
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
