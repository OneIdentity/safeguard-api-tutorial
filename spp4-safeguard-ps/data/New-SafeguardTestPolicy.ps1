Param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$PolicyName,
    [Parameter(Mandatory=$true,Position=1)]
    [string]$AssetName,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$AccountName
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrEmpty($SafeguardSession.AccessToken)) { Write-Error "You must be logged in using Connect-Safeguard." }
try { $script:Me = (Get-SafeguardLoggedInUser) } catch { Write-Error "You must be logged in using Connect-Safeguard." }

try { $script:Account = (Get-SafeguardPolicyAccount $AssetName $AccountName) } catch { Write-Error "Unable to find account $AssetName/$AccountName" }

# Get or create entitlement
try {
    $script:Entitlement = (Get-SafeguardEntitlement $PolicyName)
}
catch {
    $script:Entitlement = (New-SafeguardEntitlement $PolicyName)
}

# Add yourself as a member
Invoke-SafeguardMethod core POST "Roles/$($script:Entitlement.Id)/Members/Add" -JsonBody "[{`"PrincipalKind`":`"User`",`"Id`":$($script:Me.Id)}]" | Out-Null

# Get or create access policy
$script:Policy = (Get-SafeguardAccessPolicy -EntitlementToGet $script:Entitlement.Id)
$script:JsonBody = "{
    `"Name`": `"$PolicyName`",
    `"RoleId`": $($script:Entitlement.Id),
    `"AccessRequestProperties`": {
        `"AccessRequestType`": `"Password`",
        `"AllowSimultaneousAccess`": true
    },
    `"ApproverProperties`": {
        `"RequireApproval`": false
    },
    `"ScopeItems`": [{
        `"Id`": $($script:Account.Id),
        `"ScopeItemType`": `"Account`"
    }]
}"
if (-not $script:Policy) {
    $script:Policy = (Invoke-SafeguardMethod core POST "AccessPolicies" -JsonBody $script:JsonBody)
}
else {
    Invoke-SafeguardMethod core PUT "AccessPolicies/$($script:Policy.Id)" -JsonBody $script:JsonBody | Out-Null
}

Write-Host -ForegroundColor Yellow "Entitlement:"
Get-SafeguardEntitlement $script:Entitlement.Id -Fields Id,Name,Members.Id,Members.DisplayName | Out-Host

Write-Host -ForegroundColor Yellow "Access Policy:"
Get-SafeguardAccessPolicy $script:Policy.Id -Fields Id,Name,AccessRequestProperties.AccessRequestType,ScopeItems.ScopeItemType,ScopeItems.Id,ScopeItems.Name | Out-Host
