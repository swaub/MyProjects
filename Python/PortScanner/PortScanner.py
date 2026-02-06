import socket
import argparse
import threading
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime

def scan_port(target, port):
    """Scans a single port."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(1)
            result = s.connect_ex((target, port))
            if result == 0:
                try:
                    service = socket.getservbyport(port)
                except:
                    service = "unknown"
                return f"OPEN  | Port {port:<5} ({service})"
    except:
        pass
    return None

def main():
    parser = argparse.ArgumentParser(description="Multi-threaded Port Scanner")
    parser.add_argument("target", help="Target IP or Hostname")
    parser.add_argument("-p", "--ports", default="1-1024", help="Port range (e.g., 1-1024 or 22,80,443)")
    parser.add_argument("-t", "--threads", type=int, default=50, help="Number of threads (default: 50)")
    
    args = parser.parse_args()
    
    target_ip = args.target
    try:
        target_ip = socket.gethostbyname(args.target)
    except socket.gaierror:
        print(f"Error: Could not resolve hostname {args.target}")
        return

    print(f"Starting scan on {args.target} ({target_ip})")
    print(f"Time: {datetime.now()}")
    print("-" * 40)

    # Parse ports
    ports = []
    if "-" in args.ports:
        start, end = map(int, args.ports.split("-"))
        ports = range(start, end + 1)
    else:
        ports = map(int, args.ports.split(","))

    open_ports = []
    
    with ThreadPoolExecutor(max_workers=args.threads) as executor:
        futures = {executor.submit(scan_port, target_ip, port): port for port in ports}
        for future in futures:
            result = future.result()
            if result:
                print(result)
                open_ports.append(result)

    print("-" * 40)
    print(f"Scan complete. Found {len(open_ports)} open ports.")

if __name__ == "__main__":
    main()
