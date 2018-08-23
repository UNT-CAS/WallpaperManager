function Get-Cards {
    param (
        [Parameter()]
        [String[]]
        $CardPath ='HKLM:\SYSTEM\CurrentControlSet\Hardware Profiles\UnitedVideo\CONTROL\VIDEO\'
    )

    try {
        $Cards = Get-ChildItem $CardPath -ErrorAction Stop
    } catch {
        Throw('Error getting graphics cards')
    }
 
    return $Cards
}