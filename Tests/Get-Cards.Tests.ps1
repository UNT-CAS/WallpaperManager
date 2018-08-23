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
        Remove-Variable -Scope 'Script' -Name 'Cards' -Force -ErrorAction SilentlyContinue

        Context $test.Name {
            if ($test.Output.Throws) {
                Mock Get-ChildItem {
                    Throw 'Error getting cards'
                }

                It "Get-Cards Throws" {
                    { $script:Cards = Get-Cards } | Should Throw
                }
                continue
            }

            Mock Get-ChildItem {
                $File = Join-Path -Path (Join-Path -Path $exampleDirectory -ChildPath 'References' -Resolve) -ChildPath 'cards.txt' -Resolve
                return Get-Content $File | Out-String | ConvertFrom-Json
            }

            It "Get-Cards Does Not Throw" {
                { $script:Cards = Get-Cards } | Should Not Throw
            }

            It 'Should exist' {
                $Cards | Should Not BeNullOrEmpty
            }

            It "Should be $($test.Output.Type)" {
                $Cards.GetType().Fullname | Should Be $test.Output.Type
            }

            It "Should have $($Test.Output.Count) items" {
                $Cards.Count | Should be $test.Output.Count
            }
        }
    }
}