function Get-LatestGalleryVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [ValidateSet("stable", "prerelease")]
        [string]$Type
    )

    try {
        $onlineVersions = Find-Module -Name $ModuleName -AllowPrerelease -AllVersions
    } catch {
        if ($_.Exception.Message -like "*No match was found*") {
            Write-Host "Module $ModuleName not found in the gallery"
            return $null
        } else {
            throw
        }
    }

    Write-Host "Found $($($onlineVersions.Count)) versions of $ModuleName in the gallery"

    $version = $null

    if ($Type -eq "stable") {
        $latestStableVersion = $onlineVersions `
            | Where-Object { $_.Version -notlike "*prerelease*" } `
            | Sort-Object { [semver]$_.Version } -Descending `
            | Select-Object -First 1 -ExpandProperty Version
        
        $version = [semver]$latestStableVersion
    } else {
        $latestPrereleaseVersion = $onlineVersions `
            | Where-Object { $_.Version -like "*prerelease*" } `
            | Sort-Object { [semver]$_.Version } -Descending `
            | Select-Object -First 1 -ExpandProperty Version

        $version = [semver]$latestPrereleaseVersion
    }

    if ($null -eq $version) {
        Write-Host "No version found for type $Type"
        return $null
    }

    Write-Host "Latest $Type version: $version"
    
    return $version
}
