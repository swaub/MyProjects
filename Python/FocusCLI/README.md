# FocusCLI

A minimalist Pomodoro timer for the terminal. It tracks work/break cycles and sends desktop notifications.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/FocusCLI
```

### Option 2: Run from Source
1.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2.  Run the script:
    ```bash
    python3 FocusCLI.py
    ```

## ⚙️ Options
*   `-w`, `--work`: Work duration in minutes (default: 25).
*   `-b`, `--break-time`: Short break duration (default: 5).
*   `-l`, `--long-break`: Long break duration (default: 15).
*   `-c`, `--cycles`: Cycles before a long break (default: 4).

## 🛠️ Compilation
```bash
pip install pyinstaller plyer dbus-python
pyinstaller --onefile FocusCLI.py
```
