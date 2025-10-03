# Memory Monitor

A real-time process memory monitoring and analysis tool for Windows. Track system memory usage, identify memory-hungry processes, and monitor individual process memory consumption.

## Features

- **System Memory Overview** - Total, used, and available physical/virtual memory
- **Visual Memory Bar** - Graphical representation of memory usage
- **Top Processes** - List of memory-consuming processes sorted by usage
- **Process Details** - Detailed information for individual processes
- **Real-Time Monitoring** - Live memory tracking for specific processes
- **Interactive Mode** - User-friendly menu-driven interface
- **Command-Line Mode** - Direct process monitoring via command line

## Requirements

- **Windows** - Windows 7 or later
- **C++17** - Compiler with C++17 support
- **CMake 3.10+** - For building (optional)

## Building

### Using CMake (Recommended)

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

### Using Visual Studio

```bash
cl /std:c++17 /O2 main.cpp /Fe:memory_monitor.exe psapi.lib
```

### Using MinGW

```bash
g++ -std=c++17 -O2 main.cpp -o memory_monitor.exe -lpsapi
```

## Usage

### Interactive Mode (Default)

```bash
memory_monitor
```

Launches interactive menu with:
1. Refresh - Update memory statistics
2. View process details - Detailed info for specific PID
3. Monitor specific process - Real-time monitoring
4. Exit - Close application

### Monitor Specific Process

```bash
memory_monitor -p <PID>
```

Example:
```bash
memory_monitor -p 1234
```

Monitors process with PID 1234 in real-time, updating every 500ms.

### Help

```bash
memory_monitor -h
```

## Display Information

### System Memory Status

```
╔════════════════════════════════════════════════════════════════════════╗
║                        SYSTEM MEMORY STATUS                            ║
╚════════════════════════════════════════════════════════════════════════╝

Physical Memory:
  Total:      16.00 GB
  Used:       8.45 GB
  Available:  7.55 GB
  Usage:      53%

Virtual Memory:
  Total:      64.00 GB
  Used:       12.30 GB
  Available:  51.70 GB

  [█████████████████████████░░░░░░░░░░░░░░░░░░░░░░░] 53%
```

### Top Processes

```
╔════════════════════════════════════════════════════════════════════════╗
║                      TOP MEMORY CONSUMING PROCESSES                    ║
╚════════════════════════════════════════════════════════════════════════╝

PID     Process Name              Memory (MB)    Peak (MB)
----------------------------------------------------------------------
4892    chrome.exe                1250           1580
7364    firefox.exe               980            1120
2156    code.exe                  750            890
1234    java.exe                  650            720
...
```

### Process Details

```
╔════════════════════════════════════════════════════════════════════════╗
║                        PROCESS DETAILS                                 ║
╚════════════════════════════════════════════════════════════════════════╝

Process Name:        chrome.exe
Process ID (PID):    4892

Memory Usage:
  Working Set:       1.22 GB
  Peak Working Set:  1.54 GB
  Private Bytes:     1.18 GB
  Virtual Size:      2.45 GB

CPU Time:            125.45 seconds
Handle Count:        1250
```

### Real-Time Monitoring

```
Monitoring Process ID: 4892
Press Ctrl+C to stop...

Working Set:   1.22 GB     | Private:   1.18 GB     | Peak:   1.54 GB
```

## Memory Metrics Explained

### Working Set
- **Description**: Physical memory (RAM) currently used by the process
- **Includes**: Code, data, and shared DLLs loaded in RAM
- **Use Case**: Monitor current RAM consumption

### Peak Working Set
- **Description**: Maximum RAM used by process since it started
- **Use Case**: Identify peak memory usage patterns

### Private Bytes
- **Description**: Memory committed exclusively to this process
- **Excludes**: Shared DLLs and memory-mapped files
- **Use Case**: True memory footprint of process

### Virtual Size
- **Description**: Total virtual address space reserved
- **Includes**: Committed and reserved memory
- **Use Case**: Monitor address space usage (32-bit vs 64-bit)

## Use Cases

### 1. Identify Memory Leaks

```bash
# Monitor process continuously
memory_monitor -p 1234
```

Watch for steadily increasing memory usage that never decreases (memory leak indicator).

### 2. Performance Optimization

Use interactive mode to:
- Identify top memory consumers
- Compare memory usage across processes
- Find processes to optimize or close

### 3. System Diagnostics

Check system memory status:
- Total memory available
- Current memory pressure
- Virtual memory usage

### 4. Development Testing

Monitor your application during testing:
```bash
memory_monitor -p <your_app_pid>
```

Verify memory usage stays within acceptable limits.

### 5. Server Monitoring

Track server process memory:
```bash
# Monitor web server
memory_monitor -p <nginx_pid>

# Monitor database
memory_monitor -p <mysql_pid>
```

## Performance

- **Refresh Rate**: 500ms in monitoring mode
- **CPU Impact**: < 1% CPU usage
- **Memory Footprint**: ~5-10 MB

## Technical Details

### Windows APIs Used

- `GlobalMemoryStatusEx()` - System memory statistics
- `CreateToolhelp32Snapshot()` - Process enumeration
- `GetProcessMemoryInfo()` - Process memory counters
- `VirtualQueryEx()` - Virtual memory information
- `GetProcessTimes()` - CPU time statistics
- `GetProcessHandleCount()` - Handle count

### Memory Counters

Uses `PROCESS_MEMORY_COUNTERS_EX` structure:
- `WorkingSetSize` - Physical memory in use
- `PeakWorkingSetSize` - Maximum physical memory used
- `PrivateUsage` - Private bytes (commit charge)
- `PageFaultCount` - Page faults
- `QuotaPagedPoolUsage` - Paged pool usage
- `QuotaNonPagedPoolUsage` - Non-paged pool usage

## Common Issues

### Access Denied

Some system processes require administrator privileges:
```bash
# Run as administrator
runas /user:Administrator memory_monitor.exe
```

### Process Not Found

- Verify PID is correct: Use Task Manager
- Process may have terminated
- Check for typos in PID

### Inaccurate Memory Readings

- Some memory is shared between processes
- Virtual memory includes reserved but uncommitted pages
- Different tools may report slightly different values

## Troubleshooting

### Build Errors

Missing psapi.lib:
```bash
# Ensure Windows SDK is installed
# Link explicitly: /link psapi.lib
```

### Runtime Errors

"Process terminated or access denied":
- Process ended during monitoring
- Insufficient permissions
- Run as administrator

## Comparison with Task Manager

| Feature | Memory Monitor | Task Manager |
|---------|---------------|--------------|
| Real-time updates | ✓ Every 500ms | ✓ Slower |
| Command-line interface | ✓ Yes | ✗ No |
| Process details | ✓ Detailed | ✓ Detailed |
| CPU usage | Basic | Detailed |
| Memory breakdown | ✓ Comprehensive | ✓ Basic |
| Scriptable | ✓ Yes | ✗ No |

## Best Practices

### Monitoring Production Systems
- Use command-line mode for automation
- Log output for later analysis
- Set up alerts for memory thresholds

### Development
- Monitor during stress tests
- Check for memory leaks in long-running tests
- Compare before/after optimization

### General Use
- Close unnecessary processes
- Monitor system memory before heavy workloads
- Identify background processes consuming RAM

## Future Enhancements

Potential features for future versions:
- [ ] Linux/macOS support
- [ ] Memory leak detection algorithm
- [ ] Historical memory graphs
- [ ] Export to CSV/JSON
- [ ] Memory alerts/notifications
- [ ] Network memory usage
- [ ] GPU memory monitoring

## Examples

### Batch Monitoring Script

```batch
@echo off
REM Monitor all Chrome processes

for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq chrome.exe" /FO LIST ^| find "PID:"') do (
    echo Monitoring Chrome PID: %%i
    memory_monitor.exe -p %%i
)
```

### PowerShell Integration

```powershell
# Get top memory process
$proc = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 1
Write-Host "Monitoring: $($proc.Name) (PID: $($proc.Id))"
.\memory_monitor.exe -p $proc.Id
```

## Contributing

When contributing:
1. Test on different Windows versions
2. Verify memory calculations are accurate
3. Handle edge cases (process termination, access denied)
4. Update documentation for new features

## License

This project is released under MIT License.

## Disclaimer

This tool is for monitoring and diagnostic purposes. Use responsibly and respect system permissions.

**Notes:**
- Requires appropriate permissions for some system processes
- Memory readings may vary slightly from other tools
- Virtual memory includes reserved but uncommitted pages

---

**Author**: swaub
**Version**: 1.0.0
**Platform**: Windows
**Last Updated**: October 2025
