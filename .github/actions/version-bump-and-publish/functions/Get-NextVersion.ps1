function Get-NextVersion {
    param (
        [Parameter(Mandatory = $true)]
        $ModuleName,
        [Parameter(Mandatory = $true)]
        [ValidateSet("stable", "prerelease")]
        [string]$Type
    )

    $latestGalleryStableVersion = Get-LatestGalleryVersion -Type "stable" -ModuleName $ModuleName
    $latestGalleryPrereleaseVersion = Get-LatestGalleryVersion -Type "prerelease" -ModuleName $ModuleName
    $localModuleVersion = Get-LocalModuleVersion -ModuleName $ModuleName

    if ($Type -eq "stable") {
        if ($null -eq $latestGalleryStableVersion) {
            Write-Host "No stable version found in the gallery, setting next stable version to local module version"
            return [semver]::new($localModuleVersion.Major, $localModuleVersion.Minor, $localModuleVersion.Patch)
        }
        return Get-NextStableVersion `
            -LocalModuleVersion $localModuleVersion `
            -LatestGalleryStableVersion $latestGalleryStableVersion `
            -LatestGalleryPrereleaseVersion $latestGalleryPrereleaseVersion
    } else {
        if ($null -eq $latestGalleryPrereleaseVersion) {
            Write-Host "No prerelease version found in the gallery, setting next prerelease version to local module version"
            return [semver]::new($localModuleVersion.Major, $localModuleVersion.Minor, $localModuleVersion.Patch)
        }
        return Get-NextPrereleaseVersion `
            -LocalModuleVersion $localModuleVersion `
            -LatestGalleryStableVersion $latestGalleryStableVersion `
            -LatestGalleryPrereleaseVersion $latestGalleryPrereleaseVersion
    }
}