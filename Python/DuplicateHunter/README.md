# DuplicateHunter

A powerful CLI tool to reclaim disk space by identifying and deleting duplicate files based on content hashing (SHA-256).

## 🚀 Usage

### Option 1: Run Executable (Easiest)
**Linux:**
```bash
./bin/DuplicateHunter /path/to/folder
```

**Windows (if compiled):**
```cmd
bin\DuplicateHunter.exe C:\Path\To\Folder
```

### Option 2: Run from Source
1.  Install Python 3.8+.
2.  Run the script:
    ```bash
    python3 DuplicateHunter.py /path/to/folder
    ```

## ⚙️ Options
*   `folder`: The directory to scan (recursive).
*   `--delete`: **Caution!** If provided, duplicates will be permanently deleted (keeping the first occurrence).

## 🛠️ Compilation
To build a standalone executable for your OS:
```bash
pip install pyinstaller
pyinstaller --onefile DuplicateHunter.py
```
