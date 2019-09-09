function Set-LockScreenWallpaper{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $False)]
        [String]
        $DownloadDirectory = $env:LocalWallpaperDirectory,

        [Parameter(Mandatory = $False)]
        [String]
        $SyncedDirectory = $env:SyncedWallpaperDirectory,

        [Parameter(Mandatory = $False)]
        [String]
        $WallpaperName = "backgroundDefault.jpg",

        [Parameter(Mandatory = $False)]
        [String]
        $URL = $env:WallpaperURLFormatter
    )

    Start-Transcript -LiteralPath ('{0}\Logs\Set-LockScreenWallpaper.ps1.log' -f $env:SystemRoot) -IncludeInvocationHeader -Force

    Write-Information "################################################"
    Write-Information "# Started $(Get-Date)"

    # $SyncedDir = $env:SyncedWallpaperDirectory
    Write-Information "Synced Dir: $SyncedDirectory"

    # $DownloadDir = $env:LocalWallpaperDirectory
    Write-Information "Download Dir: $DownloadDirectory"

    # $Wallpaper = "wallpaper.jpg"
    Write-Information "Wallpaper: $WallpaperName"

    # $URL = $env:WallpaperURLFormatter
    Write-Information "URL: $URL"

    $DownloadDirectory = Get-DownloadDirectory -DownloadDirectory $DownloadDirectory

    Write-Information "Download Dir Exists: $(Test-Path $DownloadDirectory)"

    $Cards = Get-Cards
    $Monitors = Get-Monitors -Cards $Cards
    $Resolution = Get-PrimaryMonitorResolution -Monitors $Monitors

    Write-Information "Downloading ..."

    Write-Information "URL: $($URL -f $Resolution.Width, $Resolution.Height)"

    $ImagePath = (Join-Path $DownloadDirectory $WallpaperName)
    Invoke-WebRequest ($URL -f $Resolution.Width, $Resolution.Height) -OutFile $ImagePath -UseBasicParsing

    if (((Get-ItemProperty $ImagePath -ErrorAction 'Ignore').Length -eq 0) -and (Test-Path (Join-Path $SyncedDirectory $WallpaperName))) {
        Write-Warning "Didn't download; pulling from synced."
        Copy-Item (Join-Path $SyncedDirectory $WallpaperName) $ImagePath -Force
    } else {
        Write-Information "Downloaded File Exists: $ImagePath"
    }

    Write-Information "################################################"
    Stop-Transcript
}
