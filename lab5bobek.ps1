$disks = @()
[string]$temp = ""
[int]$count = 0
[string]$fileName = $args[0]

if ($fileName -eq "") {
    Write-Host "Error. An argument is empty"
    pause
    exit
}

for ([byte]$ch = [char]'a'; $ch -le [char]'z'; $ch++)  
{  
    $disks += [char]$ch  
}  

foreach ($disk in $disks){
    if (Test-Path $disk':\') {
        Set-Location $disk':\'
        $loc = Get-Location
        Write-Host $loc
        Get-ChildItem -file -Recurse | ForEach-Object -process {
            
            if ($_.Name.ToString() -eq $fileName){
                $count++
                Start-Process $_.FullName
                pause
            }

            if ($temp -eq $_.Directory.ToString()) {
                return
            } else {
                write-host $_.Directory
                $temp = $_.Directory.ToString()
            }

        } -end {

            if ($count -eq 0) {
                Write-Host "I've found nothing."
            } else {
                Write-Host "I've found $count files"
            }
        }
    }
}
pause
exit