[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory = $true)]
    [string]$ModuleName,
    [Parameter(Mandatory = $true)]
    [string]$RepositoryRoot,
    [Parameter(Mandatory = $true)]
    [ValidateSet("stable", "prerelease")]
    [string]$Type
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

# Validate required env vars when running in github
if ($env:CI) {
    if ($null -eq $env:GH_TOKEN) {
        throw "GH_TOKEN environment variable is not set. Please set it to a valid GitHub token."
    }
    if ($null -eq $env:PSGALLERY_API_KEY) {
        throw "PSGALLERY_API_KEY environment variable is not set. Please set it to a valid PSGallery API key."
    }
}

# Location of the main module
$ThisModulePath = "$RepositoryRoot/$ModuleName"

# Build the module
if (Test-Path "$ThisModulePath/Build.ps1") {
    & "$ThisModulePath/Build.ps1"
}

# Set the module path to include the local module
$separator = if ($IsWindows) { ";" } else { ":" }
$env:PSModulePath = @($env:PSModulePath, $ThisModulePath) -join $separator

# Run tests
if ($WhatIfPreference) {
    Write-Host "WhatIf: Would have run tests"
} else {
    if (Test-Path "$RepositoryRoot\$ModuleName.Tests") {
        Invoke-Pester -Path $RepositoryRoot -CI -ExcludeTag "ExcludeCI"
    } else {
        Write-Host "Test project not found at $RepositoryRoot\$ModuleName.Tests, skipping tests"
    }
}

# If last commit was the version bump, skip it
$lastCommitUser = git log -1 --pretty=%aN
if ($Type -ne "stable" -and $lastCommitUser -like "*via GitHub Actions*") {
    Write-Host "Last commit was a github actions push, skipping version bump this time around"
    return
}

# Load the functions
$functions = Get-ChildItem -Path "$PSScriptRoot/functions" -Filter "*.ps1" -Recurse
foreach ($function in $functions) {
    . $function.FullName
}

# Get the next version
$newVersion = Get-NextVersion -Type $Type

# Bump the version in the module manifest
if ($WhatIfPreference) {
    Write-Host "WhatIf: Would have bumped version to $newVersion"
} else {
    Write-Host "Bumping version to $newVersion"
    Update-ModuleManifest -Path "$RepositoryRoot\$ModuleName\$ModuleName.psd1" -ModuleVersion ([version]$newVersion)
    git config --global user.name 'Shaun Lawrie (via GitHub Actions)'
    git config --global user.email 'shaun.r.lawrie@gmail.com'
    git add (Join-Path $RepositoryRoot "$ModuleName" "$ModuleName.psd1")
    $changes = git diff --cached --name-only
    if ($changes) {
        git commit -m "Bump version to $newVersion"
        git push
    }
}

# Add pre-release label if applicable
if ($newVersion.PreReleaseLabel) {
    if ($Type -ne "prerelease") {
        throw "Pre-release label $($newVersion.PreReleaseLabel) is not applicable for stable releases"
    }

    if ($WhatIfPreference) {
        Write-Host "WhatIf: Would have set pre-release version $($newVersion.PreReleaseLabel)"
    } else {
        Update-ModuleManifest -Path $RepositoryRoot\$ModuleName\$ModuleName.psd1 -PrivateData @{ Prerelease = $newVersion.PreReleaseLabel }
    }
}

# Publish to gallery
if ($WhatIfPreference) {
    Write-Host "WhatIf: Would have published module to gallery"
} else {
    Import-Module .\$ModuleName\$ModuleName.psd1 -Force
    Publish-Module -Name $ModuleName -Exclude "Build.ps1" -NugetApiKey $env:PSGALLERY_API_KEY -AllowPrerelease
}

# Create a gh release for it
if ($WhatIfPreference) {
    Write-Host "WhatIf: Would have created a gh release"
} else {
    if ($Type -eq "stable") {
        gh release create "v$newVersion" --target main --generate-notes
    } else {
        gh release create "v$newVersion" --target prerelease --generate-notes --prerelease
    }
}

Write-Host "Version bump and publish completed."