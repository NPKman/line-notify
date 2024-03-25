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

# ถ้ามีบริการหยุดทำงาน แจ้งเตือนผ่านไลน์
if ($stoppedServices.Count -gt 0) {
    # ข้อความที่จะส่ง
    $message = "`n name : " + $ComputerName + "`n IP : " + $ipserver + "`n Downtime : "+ $datetime +"`n Service Stop: $($stoppedServices.Name -join ', ')"

    # URL ของ LINE Notify API
    $lineNotifyUrl = "https://notify-api.line.me/api/notify"

    # Token ของ LINE Notify
    $lineToken = "nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa"

    # ส่งข้อความผ่าน LINE Notify
    Invoke-RestMethod -Uri $lineNotifyUrl -Method Post -Headers @{ "Authorization" = "Bearer $lineToken" } -Body @{ "message" = $message }
}
