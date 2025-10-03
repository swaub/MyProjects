# Bandwidth Monitor

A real-time network bandwidth monitoring utility that tracks upload/download speeds and data usage across network interfaces.

## Features

- **Real-time monitoring** - Live updates of network traffic
- **Upload/Download speeds** - Current transfer rates in human-readable format
- **Session totals** - Track total data transferred since monitoring started
- **Interface selection** - Monitor specific interfaces or all at once
- **Packet statistics** - View packet counts, errors, and drops
- **Clean interface** - Clear, organized display with auto-refresh
- **Session summary** - Final statistics when stopping the monitor

## Requirements

- Python 3.6+
- psutil library

## Installation

1. Install required dependencies:
```bash
pip install -r requirements.txt
```

Or install directly:
```bash
pip install psutil
```

## Usage

Run the script:
```bash
python bandwidth_monitor.py
```

### Options

1. **Select Network Interface:**
   - Choose a specific interface (Ethernet, Wi-Fi, etc.)
   - Or monitor all interfaces combined

2. **Set Refresh Interval:**
   - Default: 1 second
   - Enter custom interval in seconds (e.g., 0.5 for faster updates)

3. **Stop Monitoring:**
   - Press `Ctrl+C` to stop and view session summary

## Display Information

The monitor shows:

### Current Speeds
- Upload speed (bytes/sec)
- Download speed (bytes/sec)
- Combined throughput

### Session Totals
- Total data uploaded
- Total data downloaded
- Combined data transfer

### Packet Statistics
- Packets sent
- Packets received
- Errors (in/out)
- Drops (in/out)

### Session Info
- Duration (HH:MM:SS)
- Current timestamp
- Interface being monitored

## Example Output

```
============================================================
                   BANDWIDTH MONITOR
============================================================
Interface: Ethernet
Session Duration: 00:05:23
Updated: 2025-10-03 14:30:45
------------------------------------------------------------

📊 CURRENT SPEEDS:
  ↑ Upload:      1.25 MB/s
  ↓ Download:    5.67 MB/s
  ⇅ Total:       6.92 MB/s

📈 SESSION TOTALS:
  ↑ Uploaded:     45.32 MB
  ↓ Downloaded:  234.56 MB
  ⇅ Combined:    279.88 MB

📦 PACKETS:
  Sent:           125,432
  Received:       543,210

⚠️  ERRORS:
  In:                   0
  Out:                  0

❌ DROPS:
  In:                   0
  Out:                  0

============================================================
Press Ctrl+C to stop monitoring
```

## Use Cases

- **Network diagnostics** - Identify bandwidth bottlenecks
- **Data usage tracking** - Monitor how much data you're using
- **Application testing** - See real-time impact of applications on bandwidth
- **ISP verification** - Check if you're getting advertised speeds
- **Troubleshooting** - Identify unexpected network activity

## Platform Support

- **Windows** - Full support
- **Linux** - Full support
- **macOS** - Full support

## Tips

- Use shorter refresh intervals (0.5s) for more responsive monitoring
- Monitor specific interfaces for targeted diagnostics
- Run with elevated privileges for complete statistics on some systems
- Use session summary to calculate average speeds over time

## Notes

- All speeds are displayed in the most appropriate unit (B/s, KB/s, MB/s, GB/s)
- Packet errors and drops indicate potential network issues
- Some statistics may require administrator/root privileges on certain systems

## License

Personal project - All rights reserved
