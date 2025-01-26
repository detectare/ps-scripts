Clear-Host

Write-Host -ForegroundColor Red "[Eclipse Detector]"
Write-Host ""
Write-Host -ForegroundColor Blue "by @detectare"
Write-Host ""

$extensions = "*.exe", "*.dll", "*.py", "*.jar"
$strings = "mouse_event","WriteProcessMemory","GetAsyncKeyState","OnClickListener()","autoclicker.class","Clicker.class","if(isClicking)",".mousePress","anygrabber","uiAccess='false'","Reach","AutoClicker,""KeyBoard.","autoclicker","dreamagent","VeraCrypt","makecert","JnativeHook","LCLICK","RCLICK","self destruct","doomsday","Recorder","Bypassing", "Bypass","Record"
$path = "C:\Users"

$i = 0
$total = (Get-ChildItem -Path $path -Include $extensions -Recurse -File).Count
Write-Progress -Activity "Searching directories" -Status "Scanning..." -PercentComplete 0

$ErrorActionPreference = 'SilentlyContinue'

$results = @()

Get-ChildItem -Path $path -Include $extensions -Recurse -File | ForEach-Object { 
    $file = $_
    $content = Get-Content $file.FullName -Raw
    foreach ($string in $strings) {
        if ($content.Contains($string)) {
            $result = [PSCustomObject]@{
                FileName = $file.FullName
                StringMatched = $string
            }
            $results += $result
        }
    }
    $i++
    Write-Progress -Activity "Searching cheats" -Status "Scanning..." -PercentComplete (($i/$total)*100)
}

$ErrorActionPreference = 'Continue'

$results | Export-Csv -Path "Eclipse.csv" -NoTypeInformation

Write-Host "Scan completed" -ForegroundColor Green

Start-Sleep -Seconds 5
exit
