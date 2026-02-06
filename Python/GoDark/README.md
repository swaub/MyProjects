# GoDark

A privacy-focused utility to "sanitize" images by stripping all metadata (EXIF, GPS, Camera info) before sharing.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/GoDark image.jpg
```

### Option 2: Run from Source
1.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2.  Run the script:
    ```bash
    python3 GoDark.py path/to/image_or_folder
    ```

## ⚙️ Options
*   `input`: File or directory to process.
*   `-o`, `--output`: Directory to save cleaned images (default: `cleaned_images`).

## 🛠️ Compilation
```bash
pip install pyinstaller Pillow
pyinstaller --onefile GoDark.py
```
