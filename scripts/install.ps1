$ErrorActionPreference = "Stop"

Write-Host "Starting installation process..."
# install scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Host "Scoop not found. Installing Scoop..."
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
  Write-Host "Scoop is already installed. Next step.."
}
$coreApp = @(
  "git", "curl", "7zip", "wget", "fzf", 
  "make", "neovim", "starship", "fd", "eza", 
  "lua", "ripgrep", "touch", "tree-sitter",
  "sudo" 
)
foreach ($app in $coreApp) {
  if (-not (Get-Command $app -ErrorAction SilentlyContinue)) {
    Write-Host ">>> Installing $app ..."
    try {
      scoop install $app
    } catch {
      Write-Warning "!!! Error installing $app"
      Write-Warning $_.Exception.Message
    }
  }
}

# Link dotfolder
$ConfigPath = "$HOME\.config"

# install mise - using winget
Write-Host ">>> Installing mise via Winget..." -ForegroundColor Cyan
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
  try {
    winget install -e --id jdx.mise --silent --accept-source-agreements --accept-package-agreements
    Write-Host "    [OK] Mise installed." -ForegroundColor Green
  } catch {
    Write-Error "!!! Winget failed to install mise."
    exit 1
  }
  Write-Host "    [!] Refreshing Environment Variables..." -ForegroundColor DarkGray
  $UserPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
  $MachinePath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
  $env:Path = $MachinePath + ";" + $UserPath
  if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host "    [Success] Mise is ready to use!" -ForegroundColor Green
  } else {
    Write-Error "!!! Installed but cannot find 'mise' in Path. Please restart terminal."
  }
} else {
  Write-Host "    [Skip] Mise is already installed." -ForegroundColor DarkGray
}
