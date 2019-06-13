function Get-Monitors {
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [Object[]]
        $Cards
    )

    $Monitors = foreach ($Card in $Cards) {
        try {
            Get-ChildItem $Card.PSPath -ErrorAction Stop
        } catch {
            Write-Warning ('Failed to find monitors on card: {0}' -f $Card)
        }
    }

    if ($Monitors) {
        Write-Output $Monitors
    } else {
        Throw 'Failed to find monitors'
    }
}