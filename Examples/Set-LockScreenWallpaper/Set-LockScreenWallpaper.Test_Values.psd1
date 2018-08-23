@{
    DownloadDirectory = "{0}\TestDirectory"
    DownloadDirectory_f = "`$env:Temp"
    WebRequestPasses = $True
    Parameters = @{
        SyncedDirectory = "C:\Windows\SyncedDirectory"
        WallpaperName = "wallpaper.jpg"
        URL = "https://i.imgur.com/bX2Uk7C.jpg"
    }
}