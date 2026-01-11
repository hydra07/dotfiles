. "$PSScriptRoot\utils.ps1"
. "$PSScriptRoot\env.ps1"
. "$PSScriptRoot\alias.ps1"
# Import-Module
Invoke-ExternalInit "starship" { starship init powershell --print-full-init }
Invoke-ExternalInit "mise"     { mise activate pwsh --quiet }
Import-MyModules -Modules @("PSFzf", "Microsoft.WinGet.CommandNotFound")
# PSReadLine Config
$psrSettings = @{
  EditMode            = "Windows"
  PredictionSource    = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
  HistoryNoDuplicates = $true
  CompletionQueryItems = 10
}
Set-PSReadLineOption @psrSettings
# KeyHandlers
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord 'RightArrow' -Function AcceptNextSuggestionWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Encoding
[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()
