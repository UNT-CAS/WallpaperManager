@{
    Parameters = @{
        DownloadDirectory = 'temp'
    }
    DontDeleteDirectory = $True
    Output = @{
        Type = 'System.String'
        Directory = 'SomeDirectory'
    }
}