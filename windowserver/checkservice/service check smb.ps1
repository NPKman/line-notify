#$ComputerName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name;
$ComputerName = (hostname)
Write-Host $ComputerName;

$ipserver = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet0).IPAddress

write-host $ipserver;

# อ่านชื่อบริการจากไฟล์ service_name.txt
$serviceNames = Get-Content -Path "service_name.txt"

# เก็บบริการที่หยุดทำงานในอาร์เรย์
$stoppedServices = @()

# ตรวจสอบว่าบริการแต่ละตัวหยุดทำงานหรือไม่
foreach ($serviceName in $serviceNames) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service -ne $null -and $service.Status -eq 'Stopped') {
        $stoppedServices += $service
    }
}

$datetime = (Get-Date  -Format "dddd,d-m-yyyy HH:mm:ss")
write-host $datetime;
$file = "log\filecheck.txt"

#ถ้ามีบริการหยุดทำงาน แจ้งเตือนผ่านไลน์
if ($stoppedServices.Count -gt 0) {
    # ข้อความที่จะส่ง
    $message = "`n name : " + $ComputerName + "`n IP : " + $ipserver + "`n Downtime : "+ $datetime +"`n Service Stop: $($stoppedServices.Name -join ', ')"
    write-host $message
    $message | Out-File -FilePath $file -Encoding utf8
}
else {

    Remove-Item -Path $file
    Write-Host "reset-service";
}

