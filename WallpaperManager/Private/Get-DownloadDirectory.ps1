function Get-DownloadDirectory {
    param (
        [Parameter(Mandatory = $True)]
        [String]
        $DownloadDirectory
    )
    
    Write-Host "[Get-DownloadDirectory] $DownloadDirectory"

    if (-not (Test-Path $DownloadDirectory)) {
        Write-Host "Download Dir Does Not Exist, Creating"
        try {
            $DownloadDirectory = New-Item -ItemType Directory -Force -Path $DownloadDirectory -ErrorAction Stop
        } catch {
            Throw '[Get-DownloadDirectory] Failed to create directory'
        }
    }

    Write-Host "[Get-DownloadDirectory] $DownloadDirectory"

    return $DownloadDirectory
}