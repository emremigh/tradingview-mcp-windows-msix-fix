### TradingView MCP - Windows MSIX Debug Port Fix

This repo contains a developed solution to run the `--remote-debugging-port=9222` flag in the **Microsoft Store (MSIX) version of TradingView Desktop**.

The original issue that Windows users were most stuck on has been resolved in the [tradesdontlie/tradingview-mcp](https://github.com/tradesdontlie/tradingview-mcp) project.

### Issue
TradingView Desktop is now only installed as an MSIX package. Normal launch scripts cannot open the debug port → Claude MCP gives a "Server disconnected" or "failed" error.

### Solution
A PowerShell script that starts the MSIX application in debug mode using the `IApplicationActivationManager` COM API.

### How to Use

1. Install **TradingView Desktop** from the Microsoft Store.

2. Clone this repository:
   ```powershell
   git clone https://github.com/emremigh/tradingview-mcp-msix-fix.git
   cd tradingview-mcp-msix-fix
   ```

3. Launch TradingView Desktop with debug port enabled:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\launch_msix_debug.ps1
   ```

4. Verify the debug port:
   - Open your browser and navigate to:  
     `http://localhost:9222/json/version`  
   - You should see a JSON response.

5. In **Claude Desktop** → Settings → Developer → Local MCP servers:
   - Command: `node`
   - Arguments: Full path to `src/server.js` (e.g. `C:\Users\name\Documents\tradingview-mcp\src\server.js`)

### Why this method?

Most launch scripts fail because Microsoft heavily sandboxes MSIX (UWP/Store) applications and intentionally blocks command-line arguments for security reasons.

The `IApplicationActivationManager` COM interface is **Microsoft’s official API** for activating Store and MSIX applications. It allows us to launch the app while properly passing arguments (in this case, the remote debugging port) without fighting the sandbox.

This is a low-level but legitimate approach used in many enterprise deployment and automation tools. It is currently the most stable and reliable method for enabling CDP on the MSIX version of TradingView Desktop.

### Important Disclaimer

> **This tool is provided for personal, educational, and research purposes only.**  
> Using automated tools or machine-driven processes with TradingView may violate TradingView’s [Terms of Service](https://www.tradingview.com/policies/).  
> You use this script **entirely at your own risk**. The author is not responsible for any account suspension, ban, or other consequences.  
> Always respect TradingView’s rules.

**Original Project:**  
https://github.com/tradesdontlie/tradingview-mcp
