function Get-Monitors {
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [Object[]]
        $Cards
    )

    foreach ($Card in $Cards) {
        try {
            $Monitors += Get-ChildItem $Card.PSPath -ErrorAction Stop
        } catch {
            Throw('Error getting monitors')
        }
    }

    return $Monitors
}