<#
    Deployed with PSDeploy
        - https://github.com/RamblingCookieMonster/PSDeploy
#>
$PSScriptRootParent = Split-Path $PSScriptRoot -Parent
Write-Host "[Deploy] PSScriptRootParent: ${PSScriptRootParent}" -Foregroundcolor 'Blue' -BackgroundColor 'Magenta'
Write-Host "[Deploy] APPVEYOR_PROJECT_NAME: ${env:APPVEYOR_PROJECT_NAME}" -Foregroundcolor 'Blue' -BackgroundColor 'Magenta'


if (
    ($env:APPVEYOR_REPO_TAG -eq 'true') -and
    ($env:APPVEYOR_REPO_BRANCH -eq 'master')
) {
    Deploy Module {
        By PSGalleryModule WallpaperManager {
            FromSource "${PSScriptRootParent}\dev\BuildOutput\WallpaperManager"
            To PSGallery
            # Tagged Testing
            WithOptions @{
                ApiKey = $env:PSGalleryApiKey
            }
        }
    }
}