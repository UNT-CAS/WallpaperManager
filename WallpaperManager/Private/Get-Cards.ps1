function Get-Cards {
    function global:Get-OSVersion {
        return ([Environment]::OSVersion)
    }

    $OSVersion = Get-OSVersion

    Write-Verbose ('OS Version information: {0}' -f $OSVersion | Format-Table)

    Switch ($OSVersion.Version.Major) {
        6 {
            $CardPath = 'HKLM:\SYSTEM\CurrentControlSet\Hardware Profiles\UnitedVideo\CONTROL\VIDEO\'
        }

        10 {
            if ($OSVersion.Version.Build -ge '17763') {
                $CardPath ='HKLM:\SYSTEM\CurrentControlSet\Control\UnitedVideo\CONTROL\VIDEO\'
            } else {
                $CardPath = 'HKLM:\SYSTEM\CurrentControlSet\Hardware Profiles\UnitedVideo\CONTROL\VIDEO\'
            }
        }

        # default {
        #     Throw('Error getting registry card path')
        # }
    }


    try {
        $Cards = Get-ChildItem $CardPath -ErrorAction Stop
    } catch {
        Throw('Error getting graphics cards')
    }
 
    return $Cards
}