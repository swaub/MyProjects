# QuickWatermark

A batch image processing tool that applies text watermarks to all images in a folder.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/Quick-Watermark ./images
```

### Option 2: Run from Source
1.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2.  Run the script:
    ```bash
    python3 Quick-Watermark.py ./images
    ```

## ⚙️ Options
*   `input`: Folder containing images (.jpg, .png).
*   `-o`, `--output`: Output folder (default: `watermarked_output`).
*   `-t`, `--text`: Watermark text (default: `© Copyright`).

## 🛠️ Compilation
```bash
pip install pyinstaller
pyinstaller --onefile Quick-Watermark.py
```
