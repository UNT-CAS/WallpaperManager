@{
    Parameters = @{
        Monitors = @(
            @{
                PSPath = 'monitor1'
            },
            @{
                PSPath = 'monitor3'
            }
        )
    }
    Output = @{
        Type  = 'System.Collections.Hashtable'
        Count = 2
    }
}