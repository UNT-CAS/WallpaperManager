[string]           $projectDirectoryName = 'WallpaperManager'
[IO.FileInfo]      $pesterFile = [io.fileinfo] ([string] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[IO.DirectoryInfo] $projectRoot = Split-Path -Parent $pesterFile.Directory
[IO.DirectoryInfo] $projectDirectory = Join-Path -Path $projectRoot -ChildPath $projectDirectoryName -Resolve
[IO.DirectoryInfo] $exampleDirectory = [IO.DirectoryInfo] ([String] (Resolve-Path (Get-ChildItem (Join-Path -Path $ProjectRoot -ChildPath 'Examples' -Resolve) -Filter (($pesterFile.Name).Split('.')[0]) -Directory).FullName))
[IO.FileInfo]      $testFile = Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath ($pesterFile.Name -replace '\.Tests\.', '.')) -Resolve
. $testFile

[System.Collections.ArrayList] $tests = @()
$examples = Get-ChildItem $exampleDirectory -Filter "$($testFile.BaseName).*.psd1" -File

foreach ($example in $examples) {
    [hashtable] $test = @{
        Name       = $example.BaseName.Replace("$($testFile.BaseName).$verb", '').Replace('_', ' ')
    }
    Write-Verbose "Test: $($test | ConvertTo-Json)"

    foreach ($exampleData in (Import-PowerShellDataFile -LiteralPath $example.FullName).GetEnumerator()) {
        $test.Add($exampleData.Name, $exampleData.Value) | Out-Null
    }

    Write-Verbose "Test: $($test | ConvertTo-Json)"
    $tests.Add($test) | Out-Null
}

Describe $testFile.Name {
    foreach ($test in $tests) {
        [hashtable] $parameters = $test.Parameters
        Remove-Variable -Scope 'Script' -Name 'Directory' -Force -ErrorAction SilentlyContinue

        Context $test.Name {
            if ($test.Output.Throws) {
                Mock New-Item {
                    Write-Error 'Failed to create new' -ErrorAction Stop
                }

                It "Get-DownloadDirectory Throws" {
                    { $script:Directory = Get-DownloadDirectory @parameters } | Should Throw
                }
                continue
            }

            It 'Get-DownloadDirectory does not throw' {
                { $script:Directory = Get-DownloadDirectory @parameters } | Should Not Throw
            }

            It 'Should return a string' {
                $Directory.GetType().Fullname | Should Be $test.Output.Type
            }

            It 'Should exist' {
                (Test-Path $Directory) | Should Be $true
            }

            if (-not ($test.DontDeleteDirectory)) {
                Remove-Item $Directory -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}