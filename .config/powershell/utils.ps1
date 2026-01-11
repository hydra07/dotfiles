function Invoke-ExternalInit {
  param (
    [string]$CommandName,
    [scriptblock]$InitAction
  )
  if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
    &$InitAction | Out-String | Invoke-Expression
  }
}
function Import-MyModules {
  param([string[]]$Modules)
  foreach ($mod in $Modules) {
    if (Get-Module -ListAvailable $mod -ErrorAction SilentlyContinue) {
      Import-Module $mod -ErrorAction SilentlyContinue
    }
  }
}

function Invoke-ChocoInit {
  if ($env:ChocolateyInstall) {
    $chocoProfile = Join-Path $env:ChocolateyInstall "helpers\chocolateyProfile.psm1"
    if (Test-Path $chocoProfile) {
      Import-Module $chocoProfile -ErrorAction SilentlyContinue 
    }
  }
}
