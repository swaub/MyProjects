# ClipSync

A minimalist tool to instantly send your clipboard text from one computer to another over your local network.

## 🚀 Usage

### 1. On the Receiver Computer
Start listening for data:
```bash
python3 ClipSync.py --listen
```

### 2. On the Sender Computer
Copy some text, then run:
```bash
python3 ClipSync.py --send <RECEIVER_IP>
```
*Example: `python3 ClipSync.py --send 192.168.1.15`*

## ⚙️ Options
*   `-l`, `--listen`: Start Receiver mode.
*   `-s`, `--send [IP]`: Send clipboard to target IP.
*   `-p`, `--port`: Specify custom port (default: 12345).

## 🛠️ Compilation
```bash
pip install pyinstaller pyperclip
pyinstaller --onefile ClipSync.py
```
