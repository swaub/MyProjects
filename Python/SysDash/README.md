# SysDash

A beautiful, real-time system monitor for your terminal. Displays CPU usage (per core), Memory stats, and Disk usage in a dashboard layout.

## 🚀 Usage

### Option 1: Run Executable
**Linux:**
```bash
./bin/SysDash
```

### Option 2: Run from Source
1.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
2.  Run the script:
    ```bash
    python3 SysDash.py
    ```

## ⌨️ Controls
*   **Ctrl+C**: Exit the dashboard.

## 🛠️ Compilation
```bash
pip install pyinstaller psutil rich
pyinstaller --onefile SysDash.py
```
