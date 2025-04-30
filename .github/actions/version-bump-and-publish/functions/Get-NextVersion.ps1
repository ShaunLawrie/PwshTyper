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
        return Get-NextStableVersion `
            -LocalModuleVersion $localModuleVersion `
            -LatestGalleryStableVersion $latestGalleryStableVersion `
            -LatestGalleryPrereleaseVersion $latestGalleryPrereleaseVersion
    } else {
        return Get-NextPrereleaseVersion `
            -LocalModuleVersion $localModuleVersion `
            -LatestGalleryStableVersion $latestGalleryStableVersion `
            -LatestGalleryPrereleaseVersion $latestGalleryPrereleaseVersion
    }
}