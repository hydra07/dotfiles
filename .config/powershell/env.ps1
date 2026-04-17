# Env
$ENV:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
$ENV:STARSHIP_CACHE = "$HOME\.config\starship\cache"

#PATH
$USER_BIN_PATH = "D:\dev\dotfiles\tool\bin"

if (Test-Path $USER_BIN_PATH) {
  $env:PATH = "$USER_BIN_PATH;" + $env:PATH
}
