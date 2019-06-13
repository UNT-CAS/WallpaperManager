@{
    Parameters = @{
        Monitors = @(
            @{
                PSPath = 'monitor1'
            },
            @{
                PSPath = 'monitor2'
            }
        )
    }
    Output = @{
        Type  = 'System.Collections.Hashtable'
        Count = 1
    }
}