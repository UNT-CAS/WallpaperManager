function Get-PrimaryMonitorResolution {
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [Object[]]
        $Monitors
    )

    foreach ($Monitor in $Monitors) {
        $Item = Get-ItemProperty $Monitor.PSPath

        if ($Item.'Attach.ToDesktop') {
            #this is a monitor

            if (($Item.'Attach.RelativeX' -eq 0) -and ($Item.'Attach.RelativeY' -eq 0)) {
                #this is the primary monitor
                $Width = $Item.'DefaultSettings.XResolution'
                $Height = $Item.'DefaultSettings.YResolution'
            }
        }
    }

    if ((!$Width) -and (!$Height)) {
        Throw "Failed to find width and height"
    }

    return @{
        Width = $Width
        Height = $Height
    }
}