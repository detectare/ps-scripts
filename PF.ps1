$directory = "C:\Windows\Prefetch"

Clear-Host

Write-Host @"
[Cheat Detector]
"@ -ForegroundColor Red
Write-Host ""
Write-Host "Made by @detectare" -ForegroundColor Blue -NoNewline
Write-Host ""

Write-Host ""
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if (!(Test-Admin)) {
	Write-Host ""
    Write-Warning "Run this script with admin."
    Start-Sleep 10
    Exit
}

Start-Sleep -s 3

$files = Get-ChildItem -Path $directory -Filter *.pf

$hashTable = @{}
$suspiciousFiles = @{}

foreach ($file in $files) {
    try {
        if ($file.IsReadOnly) {
            if (-not $suspiciousFiles.ContainsKey($file.Name)) {
                $suspiciousFiles[$file.Name] = "$($file.Name) is read only"
            }
        }

        $reader = [System.IO.StreamReader]::new($file.FullName)
        $buffer = New-Object char[] 3
        $null = $reader.ReadBlock($buffer, 0, 3)
        $reader.Close()

        $firstThreeChars = -join $buffer

        if ($firstThreeChars -ne "MAM") {
            if (-not $suspiciousFiles.ContainsKey($file.Name)) {
                $suspiciousFiles[$file.Name] = "$($file.Name) is not a valid pf file"
            }
        }

        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256

        if ($hashTable.ContainsKey($hash.Hash)) {
            $hashTable[$hash.Hash].Add($file.Name)
        } else {
            $hashTable[$hash.Hash] = [System.Collections.Generic.List[string]]::new()
            $hashTable[$hash.Hash].Add($file.Name)
        }
    } catch {
        Write-Host "Error with file: $($file.FullName): $($_.Exception.Message)" -ForegroundColor Red
    }
}

$repeatedHashes = $hashTable.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

if ($repeatedHashes) {
    foreach ($entry in $repeatedHashes) {
        foreach ($file in $entry.Value) {
            if (-not $suspiciousFiles.ContainsKey($file)) {
                $suspiciousFiles[$file] = "$file was modified with type or echo"
            }
        }
    }
}

if ($suspiciousFiles.Count) {
	Write-Host ""
    Write-Host "Suspicius files from prefetch:" -ForegroundColor Yellow
    foreach ($key in $suspiciousFiles.Keys) {
        Write-Host "$key` : $($suspiciousFiles[$key])"
    }
} else {
	Write-Host ""
    Write-Host "Prefetch folder is clean." -ForegroundColor Green
}