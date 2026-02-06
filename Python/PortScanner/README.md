# PortScanner

A fast, multi-threaded TCP port scanner.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/PortScanner google.com
```

### Option 2: Run from Source
1.  Run the script:
    ```bash
    python3 PortScanner.py google.com
    ```

## ⚙️ Options
*   `target`: IP address or hostname.
*   `-p`, `--ports`: Range (1-100) or list (22,80).
*   `-t`, `--threads`: Concurrency level (default: 50).

## 🛠️ Compilation
```bash
pip install pyinstaller
pyinstaller --onefile PortScanner.py
```
