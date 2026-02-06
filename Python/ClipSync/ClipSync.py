import socket
import argparse
import sys
import pyperclip
from threading import Thread

DEFAULT_PORT = 12345
BUFFER_SIZE = 4096

def run_server(host='0.0.0.0', port=DEFAULT_PORT):
    """Listens for incoming clipboard data."""
    print(f"📥 ClipSync Receiver listening on {host}:{port}...")
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((host, port))
        s.listen()
        
        try:
            while True:
                conn, addr = s.accept()
                with conn:
                    print(f"Connection from {addr[0]}")
                    data = conn.recv(BUFFER_SIZE)
                    if data:
                        text = data.decode('utf-8')
                        pyperclip.copy(text)
                        print(f"✅ Clipboard updated: {text[:50]}...")
        except KeyboardInterrupt:
            print("\nStopped.")

def run_client(target_ip, port=DEFAULT_PORT):
    """Sends current clipboard content to target."""
    try:
        text = pyperclip.paste()
        if not text:
            print("⚠️ Clipboard is empty.")
            return

        print(f"📤 Sending to {target_ip}:{port}...")
        print(f"Content: {text[:50]}...")
        
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((target_ip, port))
            s.sendall(text.encode('utf-8'))
            
        print("✅ Sent!")
        
    except ConnectionRefusedError:
        print("❌ Failed: Receiver not responding.")
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    parser = argparse.ArgumentParser(description="ClipSync: Share clipboard text across computers.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-l", "--listen", action="store_true", help="Start Receiver mode")
    group.add_argument("-s", "--send", type=str, metavar="IP", help="Send clipboard to target IP")
    
    parser.add_argument("-p", "--port", type=int, default=DEFAULT_PORT, help=f"Port (default: {DEFAULT_PORT})")
    
    args = parser.parse_args()
    
    if args.listen:
        run_server(port=args.port)
    elif args.send:
        run_client(args.send, port=args.port)

if __name__ == "__main__":
    main()
