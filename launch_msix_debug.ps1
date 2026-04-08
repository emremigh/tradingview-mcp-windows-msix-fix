Add-Type @"
using System;
using System.Runtime.InteropServices;

public class TVLauncher2 {
    [ComImport, Guid("2e941141-7f97-4756-ba1d-9decde894a3d"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IApplicationActivationManager {
        int ActivateApplication(string appUserModelId, string arguments, int options, out uint processId);
        int ActivateForFile(string appUserModelId, IntPtr itemArray, string verb, out uint processId);
        int ActivateForProtocol(string appUserModelId, IntPtr itemArray, out uint processId);
    }
    [ComImport, Guid("45ba127d-10a8-46ea-8ab7-56ea9078943c"), ClassInterface(ClassInterfaceType.None)]
    class ApplicationActivationManager {}
    public static uint Launch(string aumid, string args) {
        var mgr = (IApplicationActivationManager)new ApplicationActivationManager();
        uint pid;
        mgr.ActivateApplication(aumid, args, 0, out pid);
        return pid;
    }
}
"@

# Senin AUMID'in (değişmezse bu direkt çalışır)
$aumid = "TradingView.Desktop_n534cwy3pjxzj!TradingView.Desktop"

# Eski süreçleri öldür
Get-Process -Name "TradingView" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "TradingView Desktop MSIX debug modda başlatılıyor..." -ForegroundColor Green

$processId = [TVLauncher2]::Launch($aumid, "--remote-debugging-port=9222")
Write-Host "Launched with PID: $processId" -ForegroundColor Yellow

Write-Host "6 saniye bekleniyor..." -ForegroundColor Yellow
Start-Sleep -Seconds 6

# Test et
try {
    $json = Invoke-WebRequest -Uri "http://localhost:9222/json/version" -UseBasicParsing -TimeoutSec 5
    $json.Content | ConvertFrom-Json | Format-List
    Write-Host "✅ BAŞARILI! Debug port açık ve Claude MCP bağlanabilir." -ForegroundColor Green
} catch {
    Write-Host "❌ Hâlâ bağlanamadı. Tüm TradingView pencerelerini kapatıp scripti tekrar çalıştır." -ForegroundColor Red
}