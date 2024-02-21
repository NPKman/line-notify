##########################################################
##           Copyright BY THE SHOWMAN DEVELOP           ##
##          Licensed under the SHADOW LICENSE           ##
##########################################################
##    Starting For the monitoring of the Server window  ##
##########################################################

$DiskC = "C";

$ComputerName = (Get-WmiObject -Class Win32_ComputerSystem).Name;
Write-Host $ComputerName;

$ipserver = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet0).IPAddress

write-host $ipserver;

$cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$cpu = [math]::round($cpu, 2)
$mem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
$mem = [math]::round($mem, 2)

$one_gb = 1024 * 1024 * 1024;

$used_spaceC = (get-psdrive $DiskC).free / $one_gb;
$used_spaceC = [Math]::Round($used_spaceC, 2)
$resout_driveC = $used_spaceC
$totaldiskC = (get-psdrive $DiskC).Used / $one_gb;
$totaldiskC = [Math]::Round($totaldiskC, 2)
#Write-Host $totaldiskC;


$spandiskC = $resout_driveC + $totaldiskC
#write-host "AllC :" + $spandiskC

$mindriveC = $spandiskC * (100 - 90) / 100
#Write-Host "minC :" + $mindriveC;


## line ##
$uri = 'https://notify-api.line.me/api/notify'
$token = 'Bearer nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa'  # /// ของจริง
#$token = 'Bearer 4Y2RSxVi1uVtet6DV6pD9kKqnTXrs8SLDc8vLGuATqp'   # test ///
$header = @{Authorization = $token }

$mess ="`n name : " + $ComputerName + "
IP : " + $ipserver + "
CPU : " + $cpu + " % " + "
Mem Free : " + $mem + "MB " + "
Drive C Free : " + $resout_driveC + " GB " + "
Drive C use : " + $totaldiskC + " GB "

$body = @{message = $mess }


if (($mindriveC -ge $resout_driveC)) {

    Write-Host $mess
    $body = @{message = $mess + "`n Disk C is Over 90%"}
    $res = Invoke-RestMethod -Uri $uri -Method Post -Headers $header -Body $body
    Write-Host $res

} elseif (($cpu -ge 90)) {

    Write-Host $mess
    $body = @{message = $mess + "`n CPU is Over 90%"}
    $res = Invoke-RestMethod -Uri $uri -Method Post -Headers $header -Body $body
    Write-Host $res
}

else {

    Write-Host "Stopped";
}





## Fuction ##

# #    <Fuction sent message to Lint notification> #
# function sentlLine ($msg) {

#     $uri = 'https://notify-api.line.me/api/notify'
#     $token = 'Bearer nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa'  # /// ของจริง
#     #$token = 'Bearer 4Y2RSxVi1uVtet6DV6pD9kKqnTXrs8SLDc8vLGuATqp'   # test ///
#     $header = @{Authorization = $token }
#     #$body = @{message = 'PowerShell Notification :' + $disk.Free / 1GB }
#     $body = @{message = $msg }
#     $res = Invoke-RestMethod -Uri $uri -Method Post -Headers $header -Body $body
#     Write-Host $res

# }

# #----------------------------------------------------------------#

# function Check_used_space($diskdrive) {

#     $one_gb = 1024 * 1024 * 1024;
#     $used_space = (get-psdrive $diskdrive).free / $one_gb;
#     $used_space = [Math]::Round($used_space, 2)
#     $resout_driveC = $used_space

#     return $resout_driveC;
# }