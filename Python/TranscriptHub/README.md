# TranscriptHub

A GUI application to download YouTube video transcripts and save them as Text or Markdown.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/TranscriptHub
```

### Option 2: Run from Source
1.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2.  Run the script:
    ```bash
    python3 TranscriptHub.py
    ```

## ✨ Features
*   **Automatic Title Detection:** Fetches video titles.
*   **Format Selection:** Save as `.txt` or formatted `.md`.
*   **Preview:** View the transcript before saving.
*   **Smart Fallback:** Tries manual captions first, then auto-generated ones.

## 🛠️ Compilation
```bash
pip install pyinstaller youtube_transcript_api requests
pyinstaller --onefile --noconsole TranscriptHub.py
```
