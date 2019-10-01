Param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyName,
    [Parameter(Mandatory=$true)]
    [string]$AssetName,
    [Parameter(Mandatory=$true)]
    [string]$AccountName
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrEmpty($SafeguardSession.AccessToken)) { Write-Error "You must be logged in using Connect-Safeguard." }
try { Get-SafeguardLoggedInUser } catch { Write-Error "You must be logged in using Connect-Safeguard." }

try {
    $script:Entitlement = (Get-SafeguardEntitlement $PolicyName)
}
catch {
    $script:Entitlement = (New-SafeguardEntitlement $PolicyName)
}

$script:Entitlement
