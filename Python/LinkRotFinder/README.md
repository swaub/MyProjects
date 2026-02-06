# LinkRotFinder

A multi-threaded CLI tool to scan text files (Markdown, HTML, TXT) for broken URLs.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/LinkRotFinder docs/README.md
```

### Option 2: Run from Source
1.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2.  Run the script:
    ```bash
    python3 LinkRotFinder.py docs/README.md
    ```

## ⚙️ Options
*   `file`: Path to the file to scan.
*   `-t`, `--threads`: Number of concurrent connections (default: 5).

## 🛠️ Compilation
To build a standalone executable:
```bash
pip install pyinstaller
pyinstaller --onefile LinkRotFinder.py
```
