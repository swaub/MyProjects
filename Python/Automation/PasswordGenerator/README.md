# Password Generator

A comprehensive password generation utility with customizable length, difficulty levels, and strength analysis.

## Features

- **5 Difficulty Levels** - From basic to maximum security
- **Customizable Length** - 4 to 128 characters
- **Strength Analysis** - Entropy calculation and crack time estimation
- **Character Composition** - Ensures passwords meet complexity requirements
- **Ambiguous Character Exclusion** - Optional removal of confusing characters (0O1lI|)
- **Batch Generation** - Generate up to 50 passwords at once
- **Save to File** - Export passwords with full analysis
- **Real-time Analysis** - See password strength before using it

## Requirements

- Python 3.6+
- No external dependencies (uses only standard library)

## Installation

No installation required! Just run the script:

```bash
python password_generator.py
```

## Usage

### Interactive Mode

Simply run the script and follow the prompts:

```bash
python password_generator.py
```

You'll be asked to configure:
1. **Password Length** (4-128 characters, default: 16)
2. **Difficulty Level** (1-5, default: 4)
3. **Exclude Ambiguous Characters** (optional)
4. **Number of Passwords** (1-50, default: 1)

### Difficulty Levels

| Level | Name     | Character Set                                    | Use Case                    |
|-------|----------|--------------------------------------------------|-----------------------------|
| 1     | Basic    | Lowercase letters only                           | Simple, memorable passwords |
| 2     | Simple   | Lowercase + Uppercase                            | Basic security needs        |
| 3     | Standard | Letters + Numbers                                | General purpose             |
| 4     | Strong   | Letters + Numbers + Basic Symbols (!@#$%^&*)    | **Recommended for most**    |
| 5     | Maximum  | Letters + Numbers + All Special Characters       | Maximum security needs      |

## Password Strength Analysis

Each generated password includes:

### Entropy Calculation
Measures password complexity in bits. Higher = more secure.

### Strength Rating
- 🔴 **Very Weak** (< 28 bits) - Easy to crack
- 🟠 **Weak** (28-35 bits) - Should be avoided
- 🟡 **Fair** (36-59 bits) - Acceptable for low-security
- 🟢 **Strong** (60-79 bits) - Good for most uses
- 🔵 **Very Strong** (80+ bits) - Excellent security

### Crack Time Estimation
Estimated time to crack using modern hardware (10 billion guesses/second).

### Character Composition
Confirms presence of:
- Lowercase letters
- Uppercase letters
- Numbers
- Special characters

## Example Output

```
======================================================================
                        PASSWORD GENERATOR
======================================================================

⚙️  Password Configuration:
----------------------------------------------------------------------
Password length (8-128, default: 16): 20

🔒 Difficulty Levels:
----------------------------------------------------------------------
  1. Basic        - Lowercase letters only
  2. Simple       - Lowercase + Uppercase
  3. Standard     - Letters + Numbers
  4. Strong       - Letters + Numbers + Basic Symbols (!@#$%^&*)
  5. Maximum      - Letters + Numbers + All Special Characters
----------------------------------------------------------------------

Select difficulty (1-5, default: 4): 5

Exclude ambiguous characters (0O1lI|)? (y/N): y
Number of passwords to generate (1-50, default: 1): 3

======================================================================
                     GENERATED PASSWORDS
======================================================================

Configuration:
  Length: 20 characters
  Difficulty: Maximum - Letters + Numbers + All Special Characters
  Exclude Ambiguous: Yes
  Count: 3

----------------------------------------------------------------------

Password #1:
  K#9mT@q$Zp&Vh*2Rn^Ux

  📊 Analysis:
     Length: 20 characters
     Entropy: 131.1 bits
     Strength: 🔵 Very Strong
     Estimated Crack Time: 86.3 trillion years

  📝 Composition:
     ✓ Lowercase letters
     ✓ Uppercase letters
     ✓ Numbers
     ✓ Special characters

----------------------------------------------------------------------

Password #2:
  w7&Dk^Js*3Zt@Qp#9Bm$

  📊 Analysis:
     Length: 20 characters
     Entropy: 131.1 bits
     Strength: 🔵 Very Strong
     Estimated Crack Time: 86.3 trillion years

  📝 Composition:
     ✓ Lowercase letters
     ✓ Uppercase letters
     ✓ Numbers
     ✓ Special characters

----------------------------------------------------------------------

Password #3:
  Fh2@Rx*8Wn&Yv^7Tc#5k

  📊 Analysis:
     Length: 20 characters
     Entropy: 131.1 bits
     Strength: 🔵 Very Strong
     Estimated Crack Time: 86.3 trillion years

  📝 Composition:
     ✓ Lowercase letters
     ✓ Uppercase letters
     ✓ Numbers
     ✓ Special characters

======================================================================

💾 Save passwords to file? (y/N): y

✅ Passwords saved to: passwords_20251003_143025.txt

======================================================================
Thank you for using Password Generator!
======================================================================
```

## Best Practices

### Password Length Recommendations
- **Minimum**: 12 characters for general use
- **Recommended**: 16+ characters for important accounts
- **High Security**: 20+ characters for critical systems

### Difficulty Level Recommendations
- **Level 1-2**: Only for non-sensitive, offline use
- **Level 3**: Acceptable for low-security accounts
- **Level 4**: **Recommended** for most online accounts
- **Level 5**: Maximum security for banking, email, etc.

### Usage Tips
1. **Never reuse passwords** across different accounts
2. **Use a password manager** to store generated passwords
3. **Enable 2FA** whenever possible (passwords alone aren't enough)
4. **Exclude ambiguous characters** if typing passwords manually
5. **Generate multiple options** and choose the one you like best

## Security Notes

- Passwords are generated using Python's `random` module with `random.choice()`
- For cryptographically secure passwords, consider using `secrets` module in production
- Generated passwords are not stored by the application
- Crack time estimates assume offline attack at 10 billion guesses/second
- Real-world security depends on many factors beyond password strength

## File Output

When saving passwords, files are named: `passwords_YYYYMMDD_HHMMSS.txt`

Output includes:
- All generated passwords
- Complete strength analysis for each
- Generation timestamp
- Configuration details

## Use Cases

- **Account Creation** - Generate strong passwords for new accounts
- **Password Reset** - Replace weak or compromised passwords
- **Security Audit** - Generate test passwords for security testing
- **Batch Operations** - Create multiple passwords for team accounts
- **Education** - Learn about password strength and entropy

## License

Personal project - All rights reserved
