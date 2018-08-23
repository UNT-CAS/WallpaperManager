[string]           $projectDirectoryName = 'WallpaperManager'
[IO.FileInfo]      $pesterFile = [io.fileinfo] ([string] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[IO.DirectoryInfo] $projectRoot = Split-Path -Parent $pesterFile.Directory
[IO.DirectoryInfo] $projectDirectory = Join-Path -Path $projectRoot -ChildPath $projectDirectoryName -Resolve
[IO.DirectoryInfo] $exampleDirectory = [IO.DirectoryInfo] ([String] (Resolve-Path (Get-ChildItem (Join-Path -Path $ProjectRoot -ChildPath 'Examples' -Resolve) -Filter (($pesterFile.Name).Split('.')[0]) -Directory).FullName))
[IO.FileInfo]      $testFile = Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Public' -ChildPath ($pesterFile.Name -replace '\.Tests\.', '.')) -Resolve
. $testFile

. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Get-DownloadDirectory.ps1') -Resolve)
. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Get-Cards.ps1') -Resolve)
. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Get-PrimaryMonitorResolution.ps1') -Resolve)
. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Get-Monitors.ps1') -Resolve)


[System.Collections.ArrayList] $tests = @()
$examples = Get-ChildItem $exampleDirectory -Filter "$($testFile.BaseName).*.psd1" -File

foreach ($example in $examples) {
    [hashtable] $test = @{
        Name       = $example.BaseName.Replace("$($testFile.BaseName).$verb", '').Replace('_', ' ')
    }
    Write-Verbose "Test: $($test | ConvertTo-Json)"

    foreach ($exampleData in (Import-PowerShellDataFile -LiteralPath $example.FullName).GetEnumerator()) {
        if ($exampleData.Name -eq 'DownloadDirectory') {
            $TempDownloadDirectory = $exampleData.Value
        } elseif ($exampleData.Name -eq 'DownloadDirectory_f') {
            $TempDownloadDirectoryFormatter = $exampleData.Value
        } else {
            $test.Add($exampleData.Name, $exampleData.Value) | Out-Null
        }
    }

    $test.Parameters.Add('DownloadDirectory', ($TempDownloadDirectory -f ($TempDownloadDirectoryFormatter | Invoke-Expression))) | Out-Null
    
    Write-Verbose "Test: $($test | ConvertTo-Json)"
    $tests.Add($test) | Out-Null
}

Describe $testFile.Name {
    foreach ($test in $tests) {
        [hashtable] $parameters = $test.Parameters

        Context $test.Name {
            if ($Test.Output.Throws) {
                It 'Set-LockScreenWallpaper Throws' {
                    { Set-LockScreenWallpaper @parameters } | Should Throw
                }
                continue
            }

            Mock Start-Transcript {}

            Mock Get-DownloadDirectory {
                New-Item -Type Directory -Path $DownloadDirectory -Force | Out-Null
                return $DownloadDirectory
            }

            Mock Get-Cards {
                $File = Join-Path -Path (Join-Path -Path $exampleDirectory -ChildPath 'References' -Resolve) -ChildPath 'cards.txt' -Resolve
                return Get-Content $File | Out-String | ConvertFrom-Json
            }

            Mock Get-Monitors {
                $File = Join-Path -Path (Join-Path -Path $exampleDirectory -ChildPath 'References' -Resolve) -ChildPath 'monitors.txt' -Resolve
                return Get-Content $File | Out-String | ConvertFrom-Json
            }

            Mock Get-PrimaryMonitorResolution {
                $File = Join-Path -Path (Join-Path -Path $exampleDirectory -ChildPath 'References' -Resolve) -ChildPath 'primary.txt' -Resolve
                return Get-Content $File | Out-String | ConvertFrom-Json
            }

            Mock Invoke-WebRequest {
                if ($Test.WebRequestPasses) {
                    #downloading file
                    (New-Object System.Net.WebClient).DownloadFile($URL, $ImagePath)
                }
            }

            if ($Test.UsesSyncedDirectory) {
                Mock Test-Path {
                    return $True
                }
            }

            Mock Copy-Item {}

            Mock Stop-Transcript {}

            It 'Set-LockScreenWallpaper Does Not Throw' {
               { Set-LockScreenWallpaper @parameters } | Should Not Throw
            }

            It 'Should not return anything' {
                { $script:ReturnResponse = Set-LockScreenWallpaper @Parameters } | Should not throw
                $ReturnResponse | Should BeNullOrEmpty
            }

            if (Test-Path $Parameters.DownloadDirectory) {
                Remove-Item $Parameters.DownloadDirectory -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}