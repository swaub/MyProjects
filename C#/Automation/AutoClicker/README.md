# Auto Clicker

A configurable Windows auto-clicking utility built with WPF. Automate repetitive clicking tasks with customizable intervals, positions, and click types.

## Features

### Click Configuration
- **Click Interval** - Set delay between clicks (milliseconds)
- **Click Type** - Left, Right, or Middle mouse button
- **Click Mode** - Single or Double click
- **Position Modes:**
  - Current cursor position (follows mouse)
  - Fixed position (specific X,Y coordinates)

### Repeat Options
- **Continuous** - Click until manually stopped
- **Limited** - Stop after specific number of clicks

### Hotkey Control
- **F6** - Global hotkey to start/stop clicking
- Works even when window is minimized or in background

### Statistics Tracking
- Total clicks (lifetime)
- Current run clicks
- Time elapsed
- Reset statistics option

### User-Friendly Interface
- Clean WPF design
- Real-time status updates
- Visual feedback
- Input validation

## Requirements

- Windows 10 or later
- .NET 6.0 Runtime

## Installation

### Option 1: Build from Source

1. Install [.NET 6.0 SDK](https://dotnet.microsoft.com/download/dotnet/6.0)
2. Clone or download the repository
3. Navigate to the AutoClicker folder
4. Build the project:
   ```bash
   dotnet build -c Release
   ```
5. Run the executable:
   ```bash
   dotnet run
   ```

### Option 2: Pre-built Binary

1. Download the release package
2. Extract to desired location
3. Run `AutoClicker.exe`

## Usage

### Basic Usage

1. **Launch Application**
   - Run `AutoClicker.exe`

2. **Configure Settings**
   - Set click interval (e.g., 100ms = 10 clicks per second)
   - Choose click type (Left/Right/Middle)
   - Select click mode (Single/Double)

3. **Choose Position**
   - **Current Position**: Clicks wherever cursor is pointing
   - **Fixed Position**: Clicks at specific coordinates
     - Click "Get Current" to capture current mouse position

4. **Set Repeat Mode**
   - **Repeat Forever**: Clicks until you press F6 to stop
   - **Repeat Count**: Stops after specified number of clicks

5. **Start Clicking**
   - Press F6 or click "Start" button
   - Application begins auto-clicking based on configuration

6. **Stop Clicking**
   - Press F6 again or click "Stop" button

### Example Use Cases

#### 1. Idle/Clicker Games
```
Interval: 100ms
Click Type: Left Click
Mode: Single Click
Position: Fixed (on button location)
Repeat: Forever
```

#### 2. Form Testing
```
Interval: 500ms
Click Type: Left Click
Mode: Single Click
Position: Current
Repeat: Count = 50
```

#### 3. Stress Testing
```
Interval: 10ms
Click Type: Left Click
Mode: Double Click
Position: Fixed
Repeat: Count = 1000
```

## Configuration Guide

### Click Interval
- **Minimum**: 1ms (not recommended)
- **Fast**: 10-50ms
- **Normal**: 100-500ms
- **Slow**: 1000ms+

⚠️ **Warning**: Intervals below 10ms may cause:
- System instability
- Detection by anti-cheat systems
- Unresponsive UI

### Position Modes

#### Current Position Mode
- Clicks wherever cursor is pointing
- Useful for:
  - Manual cursor movement while clicking
  - Following moving targets
  - Interactive clicking tasks

#### Fixed Position Mode
- Clicks at specific X,Y coordinates
- Useful for:
  - Clicking same button repeatedly
  - Automated workflows
  - Precise positioning requirements

**Finding Coordinates:**
1. Move cursor to desired location
2. Enable "Fixed position" mode
3. Click "Get Current" button
4. Coordinates are automatically filled

### Repeat Modes

#### Repeat Forever
- Continues until manually stopped
- Press F6 to stop at any time
- Best for: Long-running automation, idle games

#### Repeat Count
- Stops after specified clicks
- Enter desired click count
- Best for: Testing, limited operations

## Safety & Best Practices

### ⚠️ Important Warnings

1. **Use Responsibly**
   - Auto-clicking may violate Terms of Service of some applications
   - May be detected as cheating in online games
   - Could result in account bans

2. **System Stability**
   - Very fast intervals can cause system lag
   - May interfere with normal computer usage
   - Close other applications if experiencing issues

3. **Application Detection**
   - Some applications detect auto-clickers
   - Anti-cheat systems may flag unusual click patterns
   - Use appropriate intervals to avoid detection

### Recommended Practices

✅ **DO:**
- Use for legitimate automation tasks
- Test with safe intervals first
- Monitor system performance
- Use for personal productivity
- Stop if experiencing issues

❌ **DON'T:**
- Use in competitive online games
- Use with very fast intervals on important systems
- Leave running unattended for extended periods
- Use to bypass security measures
- Use in ways that violate terms of service

## Legitimate Use Cases

- **Accessibility**: Helping users with limited mobility
- **Testing**: QA testing of applications
- **Productivity**: Automating repetitive office tasks
- **Gaming**: Single-player idle/clicker games
- **Development**: Testing UI responsiveness
- **Data Entry**: Automating form submissions (with permission)

## Troubleshooting

### Application Won't Start
- Ensure .NET 6.0 Runtime is installed
- Run as Administrator if needed
- Check Windows Defender/Antivirus settings

### Hotkey Not Working
- Check if F6 is already bound to another application
- Restart application to re-register hotkey
- Run as Administrator for system-wide hotkey

### Clicks Not Registering
- Verify correct click type is selected
- Check if target application is focused
- Try increasing interval slightly
- Ensure cursor is on correct monitor (multi-monitor setups)

### Application Detected as Malware
- False positive due to mouse event simulation
- Add exception in antivirus software
- Build from source if concerned

## Technical Details

### Architecture
- **Framework**: .NET 6.0 WPF
- **Language**: C#
- **UI**: XAML with Material Design elements
- **Mouse Control**: Win32 API (user32.dll)

### Win32 APIs Used
- `mouse_event`: Simulates mouse clicks
- `SetCursorPos`: Moves cursor to coordinates
- `GetCursorPos`: Gets current cursor position
- `RegisterHotKey`: Registers global F6 hotkey

### Performance
- Minimal CPU usage when idle
- Lightweight memory footprint (~20MB)
- Timer precision: ±1-2ms
- Supports up to 100 clicks per second

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| F6 | Start/Stop clicking |
| Alt+F4 | Close application |

## Version History

### Version 1.0.0
- Initial release
- Basic click functionality
- Position modes
- Repeat options
- Statistics tracking
- F6 hotkey support

## License

Personal project - All rights reserved

## Disclaimer

This tool is provided for educational and legitimate automation purposes only. The author is not responsible for misuse of this software. Users must comply with all applicable terms of service and laws when using this application.

**Use at your own risk.**
