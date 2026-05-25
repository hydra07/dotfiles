# Alias
Set-Alias -Name vim -Value nvim
Set-Alias g git
Set-Alias file fpilot.exe
Set-Alias python3 python
# Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias ls eza
function ll
{
  if (Get-Command eza -ErrorAction SilentlyContinue)
  {
    eza -l -g --icons --group-directories-first $args
  } else
  {
    ls $args
  }
}
function lla
{
  eza -la -g --icons --group-directories-first $args 
}
function which ($command)
{
  (Get-Command -Name $command -ErrorAction SilentlyContinue).Path 
}
