$filePath = "C:\monitor\checkservice\34\log\filecheck.txt"

# ตรวจสอบว่ามีไฟล์หรือไม่
if (Test-Path $filePath -PathType Leaf) {
    # อ่านข้อความจากไฟล์ข้อความ
    $text = Get-Content -Path $filePath -Raw

    # กำหนดข้อความที่ต้องการส่ง
    $message = @{
        message = $text
    }

    # กำหนด Token ของ Line Notify
    $token = "nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa"

    # URL สำหรับส่งข้อความผ่าน Line Notify
    $url = "https://notify-api.line.me/api/notify"

    # ส่งข้อความผ่าน Line Notify
    Invoke-RestMethod -Uri $url -Method Post -Headers @{Authorization = "Bearer $token"} -Body $message
} else {
    Write-Host "ไม่พบไฟล์: $filePath"
}
