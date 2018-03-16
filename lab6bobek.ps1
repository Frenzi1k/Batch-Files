[string]$site = "www.logitech.com"

function writeToFileConsole {
    param([string]$text)
    write-host $text
    $text | Out-File $PSScriptRoot'\rezult.txt' -Append
}

function multiplyStr{
    param([char]$ch, [int]$x)
    return "$ch"*$x
}

function testConnection {
    param([string]$ip, [string]$str)
    if (Test-Connection $ip -Delay 1 -Count 1 2>$nul) {
        writeToFileConsole $str":`t"$ip"`t-`tAvailable"
    } else {
        writeToFileConsole $str":'t"$ip"`t-`tNot available"
    }
}

function slowAreas {
    [string]$result = ""
    $content = (tracert -h 16 -w 2 $site | out-string)
    writeToFileConsole $content
    $content.Split("`n") | ForEach-Object -Begin{
        writeToFileConsole "`nSlow areas of the trace"
    } -Process {
        $tempStr = $_
        while($tempStr.ToString().Contains("  ") -eq 1){
            $tempStr = $tempStr.ToString().Replace("  "," ")
        }
        try {
            if ([int]($tempStr.Split(" ")[2]) -ge 30 -or [int]($tempStr.Split(" ")[4]) -ge 30 -or [int]($tempStr.Split(" ")[6]) -ge 30){
                $result +=$tempStr+"`n"
            }
        } catch{}
    } -End {
            writeToFileConsole $result"`nEnd."
        }
}

function maxPackageSize{
    param([int]$size)
    writeToFileConsole "Searching the maximum package size"
    writeToFileConsole ("Checking size: "+$size)
    $tests = (Get-WmiObject -Class Win32_PingStatus -Filter "Address='$site' AND Timeout=1000 and NoFragmentation = True and BufferSize=$size")
    if ($tests.StatusCode -ne 11009) {
        $size++
        maxPackageSize $size
    } else {
        writeToFileConsole "Error(11009). Size $size is too big."
        writeToFileConsole ("Done. The maximum package size: "+($size-1))
    }
}

function main{
    Clear-Content $PSScriptRoot'\rezult.txt'
    $wmi = Get-WmiObject -Query "select * from Win32_NetworkAdapterConfiguration where IPEnabled=True"
    $name = $wmi.Description
    $netAdapter = Get-WmiObject -Query "select * from Win32_NetworkAdapter where MACAddress is not null and speed is not null and name='$name'"
    $ip = $wmi.IPAddress.split(' ')[0]
    $ip4Route = Get-WmiObject -Query "select * from Win32_IP4RouteTable where Name='$ip'"
    writeToFileConsole ("IPAddress:`t"+$wmi.IPAddress.split(' ')[0])
    writeToFileConsole ("DefaultIPGateway:`t"+$wmi.DefaultIPGateway)
    writeToFileConsole ("DHCPEnabled:`t"+$wmi.DHCPEnabled)
    writeToFileConsole ("DHCPServer:`t"+$wmi.DHCPServer)
    writeToFileConsole ("MACAddress:`t"+$netAdapter.MACAddress)
    writeToFileConsole ("Mask:`t"+$ip4Route.Mask)
    writeToFileConsole ("Connection speed:`t"+$netAdapter.Speed+"`tbps")
    testConnection $wmi.DNSServerSearchOrder "DNS Server"
    testConnection $site "Remote host"
    testConnection $wmi.DHCPServer "DHCP Server"
    testConnection $wmi.DefaultIPGateway "DefaultIPGateway"
    writeToFileConsole (tracert -h 3 -w 2 $site | out-string)
    slowAreas
    writeToFileConsole (arp -a | Out-String)
    writeToFileConsole (netstat -an | Out-String)
    maxPackageSize 1460
}


main
pause
exit