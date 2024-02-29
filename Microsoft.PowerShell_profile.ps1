# プロンプトの表示をカレントディレクトリだけにする
function prompt {
    Write-Host "[" -ForegroundColor Yellow -NoNewline
    Write-Host (Get-Location) -ForegroundColor Cyan -NoNewline
    Write-Host "]" -ForegroundColor Yellow
    if (HaveIAdministrativePrivileges) {
        Write-Host "[Admin]>" -ForegroundColor Red -NoNewline
    }
    else {
        Write-Host ">" -ForegroundColor Cyan -NoNewline
    }
    return " ";
}

# 管理権限で実行されているか確認
# 
# true: 管理者
# false: 一般ユーザー 
function HaveIAdministrativePrivileges {
    $WindowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsRoleStatus = $WindowsPrincipal.IsInRole("Administrators")

    return $IsRoleStatus
}

# CPU情報取得
function GetCPUInformation {
    $name = ((wmic CPU get Name)[2]).Replace("  ", "")
    $clock = (((wmic CPU get MaxClockSpeed)[2]) / 1000).ToString("0.00")

    Write-Output("{0} @ {1} GHz" -f $name, $clock)
}

# Windowsバージョン取得
function GetOSVersion {
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    # Windowsのバージョン(Windows XX XXXX)
    $ProductName = (Get-WmiObject Win32_OperatingSystem).Caption
    $ProductName = $ProductName.Replace("Microsoft ", "")
    # Windowsのメジャーバージョン
    $RegKey = "CurrentBuild"
    $MajorNumber = (Get-ItemProperty -Path $RegPath -name $RegKey).$RegKey
    # Windowsのマイナーバージョン
    $RegKey = "UBR"
    $MinorNumber = (Get-ItemProperty -Path $RegPath -name $RegKey).$RegKey
    # メジャーバージョン.マイナーバージョン
    $BuildNumber = $MajorNumber + "." + [String]$MinorNumber
    # Windowsバージョン(xxHx)
    $RegKey = "DisplayVersion"
    $DisplayVersion = (Get-ItemProperty -Path $RegPath -name $RegKey).$RegKey

    Write-Output("{0} {1} [{2}]" -f $ProductName, $DisplayVersion, $BuildNumber)
}

# PowerShellバージョン取得
function GetPowerShellVersion {
    Write-Output("PowerShell Version {0}" -f $PSVersionTable["PSVersion"])
}

# 以下メイン処理
Clear-Host
Write-Host (GetOSVersion) -ForegroundColor Green
Write-Host (GetCPUInformation) -ForegroundColor Green
Write-Host (GetPowerShellVersion) -ForegroundColor Green