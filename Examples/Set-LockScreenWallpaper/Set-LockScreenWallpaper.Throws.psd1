@{
    DownloadDirectory = "{0}\TestDirectory"
    DownloadDirectory_f = "`$env:Temp"
    UsesSyncedDirectory = $True
    Parameters = @{
        SyncedDirectory = "C:\Windows\SyncedDirectory"
        WallpaperName = "wallpaper.jpg"
        URL = "https://i.imgur.com/bX2Uk7C.jpg"
    }
    Output = @{
        Throws = $True
    }
}   