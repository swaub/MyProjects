# File Encryption Tool

A command-line file encryption/decryption utility using AES-256 encryption with password-based key derivation.

## Features

- **AES-256 Encryption** - Industry-standard encryption algorithm
- **Password Protection** - Secure password-based encryption
- **Salt & IV Generation** - Random salt and initialization vector for each file
- **CBC Mode** - Cipher Block Chaining for enhanced security
- **PKCS7 Padding** - Proper data padding for block cipher
- **Cross-Platform** - Works on Windows, Linux, and macOS

## Security Features

- **Key Derivation** - Password is hashed with SHA-256 and salted
- **Random Salt** - 16-byte random salt stored with encrypted file
- **Random IV** - 16-byte initialization vector for CBC mode
- **Secure Padding** - PKCS7 padding validation
- **No Key Storage** - Encryption key derived on-the-fly, never stored

## Requirements

- C++17 compatible compiler
- CMake 3.10 or higher (for building)
- Standard C++ library

## Building

### Using CMake (Recommended)

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

### Manual Compilation

```bash
# Linux/macOS
g++ -std=c++17 -O2 main.cpp aes.cpp sha256.cpp -o file_encrypt

# Windows (MSVC)
cl /std:c++17 /O2 main.cpp aes.cpp sha256.cpp /Fe:file_encrypt.exe
```

## Usage

### Basic Commands

```bash
# Encrypt a file
./file_encrypt -e input.txt output.enc mypassword

# Decrypt a file
./file_encrypt -d output.enc decrypted.txt mypassword
```

### Command Format

```
file_encrypt <mode> <input_file> <output_file> <password>

Modes:
  -e    Encrypt mode
  -d    Decrypt mode
```

## Examples

### Encrypting a Document

```bash
# Encrypt document.pdf
./file_encrypt -e document.pdf document.pdf.enc SecurePassword123

# Output:
# Encrypting file: document.pdf
# ✓ Encryption successful!
#   Output file: document.pdf.enc
#   Original size: 52480 bytes
#   Encrypted size: 52512 bytes
```

### Decrypting a File

```bash
# Decrypt back to original
./file_encrypt -d document.pdf.enc restored.pdf SecurePassword123

# Output:
# Decrypting file: document.pdf.enc
# ✓ Decryption successful!
#   Output file: restored.pdf
#   Decrypted size: 52480 bytes
```

### Batch Processing (Shell Script)

```bash
#!/bin/bash
# Encrypt all .txt files in directory

for file in *.txt; do
    ./file_encrypt -e "$file" "$file.enc" "MyPassword"
    echo "Encrypted: $file"
done
```

## File Format

Encrypted files have the following structure:

```
[16 bytes: Salt][16 bytes: IV][Encrypted Data with PKCS7 Padding]
```

- **Salt (16 bytes)**: Random salt for key derivation
- **IV (16 bytes)**: Initialization Vector for CBC mode
- **Encrypted Data**: AES-256-CBC encrypted file content with padding

## Password Requirements

- **Minimum Length**: 6 characters
- **Recommendations**:
  - Use at least 12 characters
  - Mix uppercase, lowercase, numbers, and symbols
  - Avoid dictionary words
  - Use unique passwords for different files

## Security Considerations

### Strong Points
✓ AES-256 encryption (industry standard)
✓ Random salt prevents rainbow table attacks
✓ Random IV prevents pattern analysis
✓ CBC mode provides better security than ECB
✓ PKCS7 padding prevents padding oracle attacks

### Limitations
⚠️ **Password Strength**: Security depends entirely on password strength
⚠️ **Key Derivation**: Uses SHA-256 (consider PBKDF2 or Argon2 for production)
⚠️ **No Authentication**: No HMAC or authentication tag (consider AES-GCM)
⚠️ **Single Iteration**: Password hashing is single-pass (use multiple iterations)

### Production Recommendations

For production use, consider:
1. **PBKDF2** or **Argon2** for key derivation (with 100,000+ iterations)
2. **AES-GCM** for authenticated encryption
3. **Key stretching** to slow down brute-force attacks
4. **HMAC** for integrity verification
5. **Secure password input** (hide from console)

## Implementation Details

### AES-256 Algorithm
- **Block Size**: 128 bits (16 bytes)
- **Key Size**: 256 bits (32 bytes)
- **Mode**: CBC (Cipher Block Chaining)
- **Padding**: PKCS7

### Key Derivation Process
1. Generate random 16-byte salt
2. Concatenate password + salt
3. Hash with SHA-256
4. Use first 32 bytes as AES key

### Encryption Process
1. Read input file
2. Generate random salt and IV
3. Derive encryption key from password
4. Apply PKCS7 padding to data
5. Encrypt with AES-256-CBC
6. Write salt + IV + encrypted data to output

### Decryption Process
1. Read encrypted file
2. Extract salt and IV (first 32 bytes)
3. Derive decryption key from password
4. Decrypt data with AES-256-CBC
5. Remove PKCS7 padding
6. Write decrypted data to output

## Common Use Cases

### 1. Secure File Backup
```bash
# Encrypt sensitive files before cloud upload
./file_encrypt -e taxes_2024.pdf taxes_2024.pdf.enc MyStrongPassword!
# Upload taxes_2024.pdf.enc to cloud
```

### 2. Email Attachments
```bash
# Encrypt document before emailing
./file_encrypt -e contract.docx contract.docx.enc SharedPassword123
# Email contract.docx.enc (send password separately)
```

### 3. USB Storage
```bash
# Encrypt files on USB drive
./file_encrypt -e sensitive_data.xlsx sensitive_data.xlsx.enc USBPassword456
```

### 4. Archive Protection
```bash
# Encrypt compressed archive
tar -czf backup.tar.gz /important/files/
./file_encrypt -e backup.tar.gz backup.tar.gz.enc ArchivePassword789
```

## Troubleshooting

### "Cannot open input file"
- Check file path and permissions
- Ensure file exists
- Use absolute path if needed

### "Password may be incorrect"
- Verify password is correct
- Check for typos
- Passwords are case-sensitive

### "Input file is empty"
- File must contain data
- Check file size: `ls -lh filename`

### Decryption produces garbage
- Wrong password used
- File may be corrupted
- File may not be encrypted with this tool

## Performance

Approximate speeds on modern hardware:
- **Encryption**: 50-100 MB/s
- **Decryption**: 50-100 MB/s

Factors affecting performance:
- File size
- CPU speed
- Disk I/O speed
- System load

## Testing

### Test Script

```bash
#!/bin/bash
# Test encryption/decryption

echo "Creating test file..."
echo "Hello, World! This is a test." > test.txt

echo "Encrypting..."
./file_encrypt -e test.txt test.enc testpassword

echo "Decrypting..."
./file_encrypt -d test.enc test_decrypted.txt testpassword

echo "Comparing files..."
diff test.txt test_decrypted.txt

if [ $? -eq 0 ]; then
    echo "✓ Test passed!"
else
    echo "✗ Test failed!"
fi

# Cleanup
rm test.txt test.enc test_decrypted.txt
```

## Implementation Notes

### AES Implementation
This project uses a custom AES implementation based on the public domain tiny-AES-c library. For production use, consider:
- OpenSSL (cross-platform, widely tested)
- Crypto++ (C++ library)
- Windows CryptoAPI (Windows only)
- CommonCrypto (macOS only)

### SHA-256 Implementation
Uses custom SHA-256 implementation. For production, use battle-tested libraries like OpenSSL.

## Contributing

When modifying the encryption:
1. Always test encryption/decryption round-trip
2. Verify padding correctness
3. Test with various file sizes
4. Check edge cases (empty files, huge files)
5. Use test vectors to verify AES implementation

## License

This project is released under MIT License. See LICENSE file for details.

AES and SHA-256 implementations are based on public domain code.

## Disclaimer

**This tool is for educational purposes.** While it uses industry-standard algorithms (AES-256, SHA-256), the implementation may not be suitable for protecting highly sensitive data without additional security measures.

For critical applications, use established cryptographic libraries like OpenSSL, which have undergone extensive security audits.

**Always:**
- Keep secure backups of important files
- Remember your passwords (no recovery possible)
- Test encryption/decryption before relying on it
- Use strong, unique passwords

---

**Author**: swaub
**Version**: 1.0.0
**Last Updated**: October 2025
