# Network Optimizer - TESTING BUILD

⚠️ **DO NOT PUSH TO GITHUB YET** - This is a testing build only!

## What This Does

A simple Windows network optimization tool with 3 main features:

1. **Ping Test** - Tests latency to 8.8.8.8 (Google DNS)
2. **Apply Optimizations** - Applies 5 safe registry tweaks:
   - Disables Network Throttling Index
   - Optimizes TCP ACK Frequency
   - Disables Nagle's Algorithm
   - Sets System Responsiveness to 10
   - Optimizes DNS Cache TTL
3. **Restore Defaults** - Removes all registry tweaks

## Building

### Requirements
- Visual Studio 2019 or later
- Windows 10/11
- C++17 support

### Build Steps
1. Open `NetworkOptimizer/NetworkOptimizer.sln` in Visual Studio
2. Build in Release or Debug mode
3. **Run as Administrator** for registry modifications

## Testing Checklist

- [ ] Build compiles without errors
- [ ] App runs without admin (ping test should work)
- [ ] App runs WITH admin (optimizations should work)
- [ ] Ping test shows realistic results
- [ ] Apply optimizations shows success message
- [ ] Restore defaults works correctly
- [ ] Test on clean Windows VM first!

## Project Structure

```
NetworkOptimizer/
├── NetworkOptimizer/
│   ├── NetworkOptimizer.cpp  - Main app & UI
│   ├── optimizer.h           - Optimizer interface
│   └── optimizer.cpp         - Registry tweaks & ping test
└── NetworkOptimizer.sln      - Visual Studio solution
```

Just 3 files! Keep it simple.

## Safety Features

✅ Administrator check before any registry changes
✅ Confirmation dialog before applying
✅ All changes are reversible
✅ Only modifies well-known, safe registry values
✅ No system file modification
✅ No driver installation

## Testing Notes

### What to Test
1. **Without Admin Rights**:
   - Ping test should work fine
   - Optimize/Restore should show admin warning

2. **With Admin Rights**:
   - All features should work
   - Check if ping improves after optimization
   - Verify restore brings back defaults

3. **Registry Verification**:
   - Before: Check registry values
   - After optimization: Verify changes
   - After restore: Verify original values

### Known Limitations
- Windows only (uses Win32 API)
- Requires restart for changes to take effect
- Ping test limited to one target (8.8.8.8)
- No automatic rollback on error yet

## Tweaks Applied

| Tweak | Registry Path | Value | Effect |
|-------|--------------|-------|--------|
| Network Throttling | `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile` | NetworkThrottlingIndex = 0xFFFFFFFF | Disables multimedia network throttling |
| TCP ACK | `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces` | TcpAckFrequency = 1 | Reduces delayed ACK timer |
| Nagle's Algorithm | `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters` | TcpNoDelay = 1 | Disables Nagle (better for gaming) |
| System Responsiveness | `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile` | SystemResponsiveness = 10 | Prioritizes foreground apps |
| DNS Cache | `HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters` | MaxCacheTtl = 86400 | 24-hour DNS cache |

All tweaks are safe and reversible.

## Next Steps (After Testing)

If testing goes well:
- [ ] Add more diagnostics (jitter, packet loss analysis)
- [ ] Add interface selection for optimizations
- [ ] Create installer
- [ ] Write full documentation
- [ ] Add before/after comparison
- [ ] Test on multiple Windows versions
- [ ] **Then** push to GitHub

## DO NOT

❌ Push to public GitHub until fully tested
❌ Test on your main PC first
❌ Add aggressive/risky tweaks
❌ Skip the restore functionality test

## Questions/Issues

Document any issues you find during testing here:
-
-
-

---

**Status**: TESTING ONLY - NOT READY FOR RELEASE
**Last Updated**: October 2025
