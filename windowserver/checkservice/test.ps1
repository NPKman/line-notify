# ระบุชื่อเซิร์ฟเวอร์และที่อยู่ของแชร์
$serverName = "10.101.1.34"
$shareName = "monitor"
$destinationPath = "C:\DestinationFolder"

# กำหนดชื่อและรหัสผ่าน
$username = "oa-adm"
$password = ConvertTo-SecureString "Charger#ADM@2023" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $password)

# เชื่อมต่อกับเซิร์ฟเวอร์และเก็บไว้ในไดรฟ์ใหม่
New-PSDrive -Name "ServerDrive" -PSProvider "FileSystem" -Root "\\$serverName\$shareName" -Credential $cred

# ดึงรายการไฟล์จากไดรฟ์ใหม่ที่เชื่อมต่อไว้
$fileList = Get-ChildItem -Path "ServerDrive:" -Recurse

# ปิดการเชื่อมต่อเมื่อเสร็จสิ้น
Remove-PSDrive -Name "ServerDrive"

# วนลูปผ่านไฟล์ทั้งหมดในรายการและคัดลอกไปยังเส้นทางปลายทาง
foreach ($file in $fileList) {
    Copy-Item -Path $file.FullName -Destination $destinationPath
}

# แสดงข้อความเมื่อเสร็จสิ้น
Write-Host "All files copied successfully to $destinationPath"
