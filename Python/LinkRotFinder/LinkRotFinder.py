import os
import re
import requests
import argparse
from concurrent.futures import ThreadPoolExecutor

# Regex to find URLs
URL_PATTERN = re.compile(r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+[/\w\.-]*')

def check_url(url):
    """Checks the status of a URL."""
    try:
        response = requests.head(url, timeout=5, allow_redirects=True)
        status = response.status_code
        if status < 400:
            return f"[OK] {status} - {url}"
        else:
            return f"[BROKEN] {status} - {url}"
    except requests.RequestException as e:
        return f"[FAILED] Error - {url} ({type(e).__name__})"

def find_links_in_file(file_path):
    """Extracts all links from a file."""
    links = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                found = URL_PATTERN.findall(line)
                links.update(found)
        return list(links)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return []

def main():
    parser = argparse.ArgumentParser(description="Find and verify links in a file (Link Rot Finder).")
    parser.add_argument("file", help="Path to the file to scan (Markdown, TXT, HTML, etc.)")
    parser.add_argument("-t", "--threads", type=int, default=5, help="Number of concurrent threads (default: 5)")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.file):
        print(f"Error: File '{args.file}' not found.")
        return

    print(f"--- Link Rot Finder ---")
    print(f"Scanning: {args.file}")
    
    links = find_links_in_file(args.file)
    
    if not links:
        print("No links found in the file.")
        return
    
    print(f"Found {len(links)} unique links. Verifying...\n")

    with ThreadPoolExecutor(max_workers=args.threads) as executor:
        results = list(executor.map(check_url, links))
    
    for result in results:
        if "[OK]" in result:
            print(f"\033[92m{result}\033[0m") # Green
        else:
            print(f"\033[91m{result}\033[0m") # Red

    print(f"\nScan complete.")

if __name__ == "__main__":
    main()
