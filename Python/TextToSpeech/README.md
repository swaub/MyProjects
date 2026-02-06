# TextToSpeech

A high-quality audio generator using Microsoft Edge's neural voices. Converts text or Markdown files into MP3/WAV.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/TextToSpeech
```

### Option 2: Run from Source
1.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2.  Run the script:
    ```bash
    python3 TextToSpeech.py
    ```

## 📝 Features
*   **Neural Voices:** Uses `en-US-Emma` (Female) and `en-US-Brian` (Male).
*   **Markdown Support:** Automatically strips Markdown syntax before reading.
*   **Pronunciation Fixes:** Handles decades (1990s -> "nineteen nineties") intelligently.

## 🛠️ Compilation
```bash
pip install pyinstaller edge-tts
pyinstaller --onefile TextToSpeech.py
```
