# ตรวจสอบว่าไฟล์ "test.txt" มีหรือไม่
if (Test-Path "filecheck.txt") {
    # อ่านข้อมูลจากไฟล์
    $content = Get-Content -Path "filecheck.txt" -Raw

    # เรียกใช้งาน API สำหรับส่งข้อความไปยังไลน์ (ใช้งานได้ต่อเมื่อคุณมี Access Token)
    function Send-LineMessage {
        param(
            [string]$Message,
            [string]$AccessToken
        )

        $headers = @{
            "Authorization" = "Bearer $AccessToken"
            "Content-Type" = "application/json"
        }

        $body = @{
            "message" = $Message
        }

        $uri = "https://notify-api.line.me/api/notify"

        Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    }

    # กำหนด Access Token ของคุณที่ได้รับจากการลงทะเบียนบอท LINE Messaging API
    $accessToken = "nehUfnZrzHkYwr9foDnaiXXuSHRWNqqB2wvi2SG7yTa"

    # ส่งข้อความไปยังไลน์
    Send-LineNotifyMessage -Message $content -AccessToken $accessToken
    Send-LineNotifyMessage -Message "Your message here." -AccessToken $accessToken
}
else {
    Write-Host "File 'filecheck.txt' does not exist."
}
