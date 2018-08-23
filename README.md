# Description

This module allows for an image to be dynamically set as the lockscreen image based off of the resolution of the primary monitor. The idea is to use this in an enterprise environment where you need to set one image with a dynamic resolution to several computers. We can achieve this by running the scripts through Group Policy as the *system* user.

# Quick Setup

1. Set the Environment Variables; see [section below](#environment-variables)
2. Install *Set-LockScreenWallpaper*: `Install-Module Set-LockScreenWallpaper`
3. Import *Set-LockScreenWallpaper*: `Import-Module Set-LockScreenWallpaper`
4. Start *Set-LockScreenWallpaper*: `Invoke-Module Set-LockScreenWallpaper`

# Environment Variables

There are 3 environment variables that we use for this module;`$env:SyncedWallpaperDirectory`, `$env:LocalWallpaperDirectory` and `$env:WallpaperURLFormatter`. I suggest setting these using the same GPO that will run the script at startup. Here's a description of each of them:

- `$env:SyncedWallpaperDirectory`: Directory where your wallpaper, with default resolution vaules, is stored. This is only used in the event the module is unable to obtain the correct resolution or image otherwise.
- `$env:LocalWallpaperDirectory`: Directory where your wallpaper will be downloaded to.
- `$env:WallpaperURLFormatter`: URL for the wallpaper that will be downloaded. Should be able to take in two parameters: *width* & *height*, respectively.
