##########################################################
##           Copyright BY THE SHOWMAN DEVELOP           ##
##          Licensed under the SHADOW LICENSE           ##
##########################################################
##    Starting For the monitoring of the Server window  ##
##########################################################

$DiskC = "C";
$DiskD = "D";
$minSize = 50;



$cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$cpu = [math]::round($cpu, 2)
$mem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
$mem = [math]::round($mem, 2)

$one_gb = 1024 * 1024 * 1024;
$used_space = (get-psdrive $DiskC).free / $one_gb;
$used_space = [Math]::Round($used_space, 2)
$resout_driveC = $used_space
$nameserver = 'ev-charger-srv02 (AIS cloud)'
$totaldisk = (get-psdrive $DiskC).Used / $one_gb;
$totaldisk = [Math]::Round($totaldisk, 2)
Write-Host $totaldisk;

$mess = " `n name : " + $nameserver + " `n IP : 10.101.1.36 `n CPU : " + $cpu + " % " + " `n Mem Available : " + $mem + " MB " + " `n Drive C in use : " + $resout_driveC + " GB " + " `n Drive C total : " + $totaldisk + " GB " +" `n Alert : Clear log success"

if (($minSize -ge $resout_driveC) ){
    Write-Host $mess

    $uri = 'https://notify-api.line.me/api/notify'
    $token = 'Bearer nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa'  # /// ของจริง
    #$token = 'Bearer 4Y2RSxVi1uVtet6DV6pD9kKqnTXrs8SLDc8vLGuATqp'   # test ///
    $header = @{Authorization = $token }
    #$body = @{message = 'PowerShell Notification :' + $disk.Free / 1GB }
    $body = @{message = $mess}
    $res = Invoke-RestMethod -Uri $uri -Method Post -Headers $header -Body $body
    Write-Host $res

}
else {
    Write-Host "Stopped";
}


## Fuction ##

#    <Fuction sent message to Lint notification> #
function sentlLine ($msg) {

    $uri = 'https://notify-api.line.me/api/notify'
    $token = 'Bearer nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa'  # /// ของจริง
    #$token = 'Bearer 4Y2RSxVi1uVtet6DV6pD9kKqnTXrs8SLDc8vLGuATqp'   # test ///
    $header = @{Authorization = $token }
    #$body = @{message = 'PowerShell Notification :' + $disk.Free / 1GB }
    $body = @{message = $msg }
    $res = Invoke-RestMethod -Uri $uri -Method Post -Headers $header -Body $body
    Write-Host $res

}

#----------------------------------------------------------------#

function Check_used_space($diskdrive) {

    $one_gb = 1024 * 1024 * 1024;
    $used_space = (get-psdrive $diskdrive).free / $one_gb;
    $used_space = [Math]::Round($used_space, 2)
    $resout_driveC = $used_space

    return $resout_driveC;
}