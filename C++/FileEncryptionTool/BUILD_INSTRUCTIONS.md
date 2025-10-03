# Build Instructions

## Required Implementation Files

This project requires AES and SHA-256 implementation files. Due to their size, they're not included in the repository.

### Option 1: Use tiny-AES-c (Recommended)

1. Download tiny-AES-c from: https://github.com/kokke/tiny-AES-c
2. Copy `aes.c` and rename to `aes.cpp`
3. Place in this directory

### Option 2: Use OpenSSL

Modify `main.cpp` to use OpenSSL's EVP API instead of custom AES implementation.

```bash
# Linux
sudo apt-get install libssl-dev

# macOS
brew install openssl

# Link with: -lssl -lcrypto
```

### Option 3: Download pre-made implementations

Download `aes.cpp` and `sha256.cpp` from a trusted cryptographic library or implement according to FIPS standards.

## Quick Build

Once you have the implementation files:

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

## Manual Build

```bash
g++ -std=c++17 -O2 main.cpp aes.cpp sha256.cpp -o file_encrypt
```

## Note

For production use, always use well-tested cryptographic libraries like OpenSSL, Botan, or Crypto++.
