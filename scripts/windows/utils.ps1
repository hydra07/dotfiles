function Show-Menu {
  param (
    [Parameter(Mandatory=$true)] $Items,
    [string]$Title = "SELECT ITEMS"
  )
  $Sel = @{}; $Cur = 0; $Max = $Items.Count - 1
  [Console]::CursorVisible = $false
  Write-Host "`n--- $Title ---" -F Cyan
  Write-Host "[↑/↓] Nav  [Space] Select  [A] All  [Esc] Cancel  [Enter] Confirm`n" -F DarkGray
  1..$Items.Count | ForEach-Object { Write-Host "" }
  $StartY = [Console]::CursorTop - $Items.Count
  try {
    while ($true) {
      [Console]::SetCursorPosition(0, $StartY)

      for ($i = 0; $i -lt $Items.Count; $i++) {
        $Name = if ($Items[$i].Name) {
          $Items[$i].Name 
        } else {
          $Items[$i].ToString() 
        }
        $Mark = "[ ]"; $Color = "Gray"; $Back = "Black"
        if ($Sel[$i]) {
          $Mark = "[x]"; $Color = "Green" 
        }
        if ($i -eq $Cur) { 
          $Back = "DarkGray"   
          $Color = "White"     
          if ($Sel[$i]) {
            $Color = "Green" 
          }
        }
        Write-Host " $Mark $Name".PadRight(50) -NoNewline -ForegroundColor $Color -BackgroundColor $Back
        Write-Host "" -BackgroundColor Black 
      }
      $Key = [Console]::ReadKey($true).Key
      switch ($Key) {
        'UpArrow'   {
          if ($Cur -gt 0) {
            $Cur-- 
          } 
        }
        'DownArrow' {
          if ($Cur -lt $Max) {
            $Cur++ 
          } 
        }
        'Spacebar'  {
          $Sel[$Cur] = -not $Sel[$Cur] 
        }
        'A'         { 
          $AllOn = $false
          for ($j=0; $j -le $Max; $j++) {
            if (-not $Sel[$j]) {
              $AllOn = $true; break 
            } 
          }
          for ($j=0; $j -le $Max; $j++) {
            $Sel[$j] = $AllOn 
          }
        }
        'Enter'     {
          return $Items | Where-Object { $Sel[$Items.IndexOf($_)] } 
        }
        'Escape'    {
          return $null 
        }
      }
    }
  } finally { 
    [Console]::CursorVisible = $true 
    [Console]::SetCursorPosition(0, $StartY + $Items.Count)
  }
}
