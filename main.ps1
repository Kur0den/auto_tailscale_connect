Import-Module BurntToast

function main {
    if ((Get-NetAdapter -InterfaceDescription "*Wi-Fi*").Status -eq "up") {
        # 特定のWi-Fi SSIDリスト
        $targetSSIDs = @("YourWiFiSSID1", "YourWiFiSSID2")

        # 接続しているWi-FiのSSIDを取得
        $wifi = (Get-NetAdapter -InterfaceDescription "*Wi-Fi*" | Get-NetConnectionProfile).Name

        # Wi-Fiが特定のSSIDリストに含まれていない場合、Tailscaleを起動
        if ($targetSSIDs -notcontains $wifi) {
            if (!(TailScaleIsConnected)) {
                sendToast "Wi-Fiが指定されたSSIDリストに含まれていないため、Tailscaleを起動します。"
                Start-Process "tailscale" -ArgumentList "up" -WindowStyle Hidden
            }
        }
        else {
            if (TailScaleIsConnected) {
                sendToast "Wi-Fiが指定されたSSIDリストに含まれているため、TailScaleを停止します。"
                Start-Process "tailscale" -ArgumentList "down" -WindowStyle Hidden
            }

        }
    }
}


function TailScaleIsConnected {
    return !((tailscale status | Select-Object -First 1 ) -match "stopped")
}


function sendToast {
    param(
        $text
    )
    New-BurntToastNotification -AppLogo ./dummy.png -Text "AutoTailScaleConnector", $text
}

main
