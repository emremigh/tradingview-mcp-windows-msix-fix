# =====================================================
#  TradingView Desktop MSIX Debug Launcher
#  For Claude MCP Integration
# =====================================================

Clear-Host

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "     TradingView Desktop MSIX Debug Launcher" -ForegroundColor Cyan
Write-Host "          Chrome DevTools Protocol Enabled" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "-> Initializing Microsoft IApplicationActivationManager..." -ForegroundColor Yellow

# COM Type Definition (Fixed for PowerShell)
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class TVLauncher {
    [ComImport]
    [Guid("2e941141-7f97-4756-ba1d-9decde894a3d")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IApplicationActivationManager {
        int ActivateApplication([MarshalAs(UnmanagedType.LPWStr)] string appUserModelId,
                                [MarshalAs(UnmanagedType.LPWStr)] string arguments,
                                int options, out uint processId);
    }

    [ComImport]
    [Guid("45ba127d-10a8-46ea-8ab7-56ea9078943c")]
    public class ApplicationActivationManager { }

    public static uint Launch(string aumid, string args = "") {
        var mgr = (IApplicationActivationManager)new ApplicationActivationManager();
        uint pid = 0;
        int hr = mgr.ActivateApplication(aumid, args, 0, out pid);
        if (hr != 0) {
            throw new Exception("Failed to launch application. HRESULT: " + hr);
        }
        return pid;
    }
}
"@ -ErrorAction Stop

$aumid = "TradingView.Desktop_n534cwy3pjxzj!TradingView.Desktop"

# Kill old instances
Get-Process -Name "TradingView" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "-> Killing old TradingView processes..." -ForegroundColor Gray
Write-Host "-> Launching TradingView Desktop with debug port 9222..." -ForegroundColor Green

try {
    $processId = [TVLauncher]::Launch($aumid, "--remote-debugging-port=9222")
    
    Write-Host "-> TradingView Desktop launched successfully!" -ForegroundColor Green
    Write-Host "   Process ID: $processId" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Waiting for debug port to initialize (6 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 6

    # Check debug port
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9222/json/version" -UseBasicParsing -TimeoutSec 5
        $json = $response.Content | ConvertFrom-Json

        Write-Host "========================================================" -ForegroundColor Green
        Write-Host "                  SUCCESS!" -ForegroundColor Green
        Write-Host "          Debug Port is OPEN and Ready for MCP" -ForegroundColor Green
        Write-Host "========================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Browser Version : $($json.Browser)" -ForegroundColor White
        Write-Host "WebSocket URL   : $($json.webSocketDebuggerUrl)" -ForegroundColor White
        Write-Host ""
        Write-Host "Claude MCP connection is now possible." -ForegroundColor Cyan
        Write-Host "Happy Trading and Coding!" -ForegroundColor Magenta

    } catch {
        Write-Host "Could not connect to debug port." -ForegroundColor Red
        Write-Host "Make sure TradingView window is open." -ForegroundColor Red
    }

} catch {
    Write-Host "Failed to launch TradingView Desktop." -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
