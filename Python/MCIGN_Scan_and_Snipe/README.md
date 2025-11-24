# Minecraft IGN Scanner and Sniper

A Python utility for scanning Minecraft username (IGN) availability and sniping usernames as they become available. Check thousands of random usernames or target specific usernames with precise timing.

## Features

- **Username Scanner** - Check availability of random Minecraft usernames
- **Configurable Length** - Generate usernames from 3-16 characters
- **Batch Checking** - Scan hundreds or thousands of usernames at once
- **Rate Limit Handling** - Automatic delay adjustment to avoid Mojang API rate limits
- **Available Username Tracking** - Maintains list of all available usernames found
- **Sniper Mode** - Attempt to claim usernames at specific drop times
- **Async Sniping** - Fast, concurrent username claiming attempts

## Requirements

- Python 3.7+
- Active internet connection
- Minecraft account (for sniping feature)

## Installation

1. Install required dependencies:
```bash
pip install -r requirements.txt
```

Or install directly:
```bash
pip install requests aiohttp
```

## Usage

### Running the Scanner

```bash
python MCIGN_Scan_and_Snipe.py
```

### Main Menu Options

```
=== MINECRAFT IGN SCANNER & SNIPER ===

1. Scan for available usernames
2. Setup sniper
3. Snipe username
4. Exit

Select option:
```

## Scanner Mode

### How It Works

1. Select option `1` from main menu
2. Enter desired username length (3-16 characters)
3. Enter how many usernames to check
4. Script generates random usernames and checks availability via Mojang API

### Example Session

```
=== USERNAME SCANNER ===
How many characters should the IGN have (3-16): 5
How many IGNs would you like to check: 100

Scanning 100 usernames of length 5...
Note: Longer delays between checks to avoid rate limiting.

abc12 is NOT available (taken).
xyz99 is NOT available (taken).
✓ AVAILABLE IGN found! qw3r5
zzz11 is NOT available (taken).
✓ AVAILABLE IGN found! np8t4
...

========================================
Finished checking 100 usernames.
Found 7 AVAILABLE username(s):
  1. qw3r5
  2. np8t4
  3. jk2m9
  4. yz7x1
  5. vb3n6
  6. cv8q2
  7. lm4p5
```

### Scanner Features

- **Random Generation**: Creates usernames using lowercase letters, numbers, and underscores
- **Smart Rate Limiting**: Automatically adjusts delays when API rate limits are hit
- **Status Codes**:
  - `200`: Username is taken
  - `204/404`: Username is **AVAILABLE**
  - `429`: Rate limited (delays automatically increased)

### Rate Limiting

The scanner implements intelligent rate limiting:
- **Normal**: 0.8 second delay between checks
- **After 1 rate limit**: 1.5 second delay
- **After 3+ rate limits**: 3 second delay
- **On rate limit hit**: Additional 3 second pause

## Sniper Mode

### Setup

1. Select option `2` from main menu
2. Enter your Minecraft account details:
   - **UUID**: Your Minecraft account UUID
   - **Bearer Token**: Authentication token from launcher
   - **Password**: Your account password

### How to Get Bearer Token

The Bearer token can be obtained from your Minecraft launcher:
1. Open Minecraft Launcher
2. Access developer tools/console (varies by launcher)
3. Look for authentication tokens in network requests
4. Copy the Bearer token value

**Note**: Be cautious with your credentials. Never share your Bearer token or password.

### Sniping a Username

1. Complete sniper setup (option 2)
2. Select option `3` from main menu
3. Enter target username to snipe
4. Optionally enter drop time for scheduled sniping
5. Script attempts to claim the username

### Scheduled Sniping

For usernames dropping at specific times:

```
Enter the username to snipe: DesiredName
Enter drop time (YYYY-MM-DD HH:MM:SS) or leave empty for immediate:
2025-10-15 14:30:00

⏰ Waiting until 2025-10-15 14:30:00 to snipe DesiredName...
```

The script will wait until the specified time and attempt to claim the username.

## API Information

### Mojang API Endpoints

The tool uses Mojang's official API:

**Check Username Availability:**
```
GET https://api.mojang.com/users/profiles/minecraft/{username}
```

**Response Codes:**
- `200` - Username exists (taken)
- `204` - Username available
- `404` - Username available
- `429` - Rate limited

## Best Practices

### For Scanning

1. **Start with reasonable batch sizes** (50-200 usernames)
2. **Don't spam requests** - respect rate limits
3. **Longer usernames** have higher availability
4. **Save results** - note down available usernames you like

### For Sniping

1. **Verify drop times** from reliable sources
2. **Test connection** before important snipes
3. **Have backup accounts** ready
4. **Account for timezone** when entering drop times
5. **Coordinate with team** if doing group snipes

## Security Considerations

⚠️ **Important Security Notes:**

- **Never share your Bearer token** - It provides full account access
- **Use strong passwords** for your Minecraft account
- **Enable 2FA** if available on your account
- **Don't run untrusted modifications** of this script
- **Be cautious** of API rate limits and potential account restrictions

## Rate Limits

Mojang API has rate limits to prevent abuse:
- **Per IP**: Limited requests per minute
- **Per Account**: Limited authentication attempts
- **Penalties**: Temporary IP bans for excessive requests

The scanner automatically handles rate limits with increasing delays.

## Troubleshooting

### Connection Errors

```
Request failed: Connection timeout
```

**Solutions:**
- Check internet connection
- Verify Mojang API is online
- Try increasing timeout values
- Check firewall settings

### Rate Limiting

```
Rate limited (#3), adjusting delay...
```

**Solutions:**
- Wait for automatic delay adjustment
- Reduce batch size
- Increase base delay in code
- Take breaks between scanning sessions

### Authentication Failures

```
Snipe failed: Invalid credentials
```

**Solutions:**
- Verify UUID is correct
- Check Bearer token is current (tokens expire)
- Confirm password is accurate
- Re-authenticate in launcher

### No Available Usernames Found

**Tips:**
- Try shorter usernames (3-5 characters are rarer)
- Scan larger batches (500-1000+)
- Use less common character patterns
- Check at different times of day

## Limitations

- **Mojang API Dependency**: Requires Mojang API to be operational
- **Rate Limits**: Cannot check unlimited usernames rapidly
- **Username Rules**: Minecraft usernames must be 3-16 characters (a-z, A-Z, 0-9, _)
- **No Guarantee**: Finding available username doesn't guarantee successful claim
- **Name Changes**: Minecraft has name change cooldown periods

## Legal & Ethical Considerations

- **Terms of Service**: Ensure usage complies with Minecraft/Mojang ToS
- **Fair Use**: Don't abuse API or attempt to circumvent security
- **Automation Limits**: Excessive automation may violate ToS
- **Account Security**: Protect your credentials
- **Respectful Usage**: Don't harass or impersonate others

## Use Cases

### Personal Username Search
- Find short, available usernames for personal use
- Check if desired username is available
- Discover creative username ideas

### Username Research
- Study username availability patterns
- Analyze character distribution in available names
- Research username trends

### Legitimate Sniping
- Claim your own expiring username on alt account
- Coordinate username swaps with friends
- Claim usernames as they become available legitimately

## Technical Details

### Dependencies

- `requests`: HTTP requests to Mojang API
- `aiohttp`: Asynchronous HTTP for fast sniping
- `asyncio`: Async/await support for concurrent operations

### API Interaction

The script uses:
- Synchronous requests for scanning (prevents API abuse)
- Asynchronous requests for sniping (speed-critical)
- Proper error handling and timeout management
- Automatic retry logic with backoff

## Examples

### Quick Scan for 5-Character Names

```bash
python MCIGN_Scan_and_Snipe.py

# Select: 1 (Scan)
# Length: 5
# Count: 100
# Wait for results
```

### Target Specific Username Drop

```bash
python MCIGN_Scan_and_Snipe.py

# Select: 2 (Setup sniper)
# Enter credentials
# Select: 3 (Snipe)
# Enter: TargetName
# Enter drop time
```

## Performance

- **Scanning Speed**: ~1-2 usernames per second (with rate limiting)
- **Batch Efficiency**: 100 usernames ≈ 2-3 minutes
- **Snipe Speed**: Milliseconds (network dependent)

## Future Enhancements

Potential features for future versions:
- [ ] Custom character set selection
- [ ] Save scan results to file
- [ ] Username pattern matching
- [ ] Multi-account sniping support
- [ ] Webhook notifications for available names
- [ ] GUI interface
- [ ] Historical availability tracking

## Disclaimer

This tool is for educational and personal use only. Users are responsible for:
- Complying with Minecraft/Mojang Terms of Service
- Protecting their account credentials
- Using the tool ethically and responsibly
- Any consequences from tool usage

**The author is not responsible for:**
- Account bans or suspensions
- Failed snipe attempts
- Credential mishandling
- API rate limit penalties

Use at your own risk and discretion.

## Contributing

When contributing, please:
1. Respect Mojang API rate limits in any modifications
2. Never commit credentials or tokens
3. Test thoroughly with alt accounts
4. Document new features clearly
5. Follow Python best practices

## License

This project is released under MIT License.

---

**Author**: swaub
**Version**: 1.0.0
**Last Updated**: October 2025

**Note**: Always verify username availability through official Mojang channels before making decisions based on this tool's output.
