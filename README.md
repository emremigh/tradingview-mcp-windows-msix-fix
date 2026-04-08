# TradingView MCP - Windows MSIX Debug Port Fix

This repo contains a working solution to run the `--remote-debugging-port=9222` flag on the **Microsoft Store (MSIX) version of TradingView Desktop**.

The most common issue Windows users face with the original [tradesdontlie/tradingview-mcp](https://github.com/tradesdontlie/tradingview-mcp) project has been resolved here.

### Issue
TradingView Desktop is now installed only as an MSIX package. Normal launch scripts cannot pass the debug port flag due to sandbox restrictions. This causes Claude MCP to show **"failed"** or **"Server disconnected"** errors.

### Solution
A PowerShell script that launches the MSIX application in debug mode using Microsoft’s official **IApplicationActivationManager COM API**.

### How to Use

1. Install **TradingView Desktop** from the Microsoft Store.

2. Clone this repository:
   ```powershell
   git clone https://github.com/emremigh/tradingview-mcp-windows-msix-fix.git
   ```

3. Place the downloaded launch_msix_debug.ps1 file in the original script folder and open and run the file path:
   ```powershell
   cd tradingview-mcp
   .\launch_msix_debug.ps1
   ```

4. Verify the debug port:
   - Open your browser and go to: `http://localhost:9222/json/version`
   - You should see a JSON response.

5. In **Claude Desktop** → Settings → Developer → Local MCP servers:
   - Command: `node`
   - Arguments: Full path to `src/server.js` (example: `D:\workdir\tradingview-mcp\src\server.js`)

### How to Find Your AUMID (If the script doesn't work)

Sometimes the PackageFamilyName changes after TradingView updates. Run this command in PowerShell:

```powershell
Get-AppxPackage *TradingView* | Format-List Name, PackageFamilyName
```

Then open `scripts\launch_msix_debug.ps1` and update this line with your own value:
```powershell
$aumid = "YourPackageFamilyName!TradingView.Desktop"
```

### Developer Mode (Recommended if you get launch errors)

1. Go to **Windows Settings → Update & Security → For developers**
2. Enable **Developer Mode**

This often resolves COM activation and permission issues.

### Why this method?

Most simple launch scripts fail because Microsoft heavily sandboxes MSIX applications and intentionally blocks command-line arguments for security reasons.

`IApplicationActivationManager` is **Microsoft’s official API** for activating Store and MSIX apps. It allows us to launch the application while properly passing the remote debugging port without fighting the sandbox.

This low-level but legitimate approach is used in many enterprise deployment tools and is currently the most stable method for enabling CDP on TradingView Desktop MSIX version.

### Important Disclaimer

> **This tool is provided for personal, educational, and research purposes only.**  
> Using automated tools or machine-driven processes with TradingView may violate TradingView’s [Terms of Service](https://www.tradingview.com/terms/).  
> You use this script **entirely at your own risk**.  
> The author is not responsible for any account suspension, ban, or other consequences.  
> Always respect TradingView’s rules.

**Original Project:**  
https://github.com/tradesdontlie/tradingview-mcp
