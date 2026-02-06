import os
import hashlib
import argparse
from collections import defaultdict

def get_file_hash(filepath, block_size=65536):
    """Calculates the SHA-256 hash of a file."""
    sha256 = hashlib.sha256()
    try:
        with open(filepath, 'rb') as f:
            while True:
                data = f.read(block_size)
                if not data:
                    break
                sha256.update(data)
        return sha256.hexdigest()
    except OSError:
        return None

def find_duplicates(folder):
    """Scans the folder and identifies duplicate files."""
    hashes = defaultdict(list)
    
    print(f"Scanning: {folder}")
    
    for root, _, files in os.walk(folder):
        for filename in files:
            filepath = os.path.join(root, filename)
            
            # Skip empty files (optional, but usually desired)
            try:
                if os.path.getsize(filepath) == 0:
                    continue
            except OSError:
                continue

            file_hash = get_file_hash(filepath)
            if file_hash:
                hashes[file_hash].append(filepath)

    duplicates = {h: paths for h, paths in hashes.items() if len(paths) > 1}
    return duplicates

def main():
    parser = argparse.ArgumentParser(description="Find duplicate files in a directory.")
    parser.add_argument("folder", help="The folder to scan.")
    parser.add_argument("--delete", action="store_true", help="Delete duplicates (keeps the first found).")
    
    args = parser.parse_args()
    
    if not os.path.isdir(args.folder):
        print("Invalid directory.")
        return

    dupes = find_duplicates(args.folder)

    if not dupes:
        print("No duplicates found.")
        return

    print(f"\nFound {len(dupes)} sets of duplicates:\n")
    
    count = 0
    bytes_saved = 0

    for file_hash, paths in dupes.items():
        print(f"Hash: {file_hash[:8]}...")
        # Keep the first one, list others
        original = paths[0]
        copies = paths[1:]
        
        print(f"  [Keep] {original}")
        for copy in copies:
            if args.delete:
                try:
                    size = os.path.getsize(copy)
                    os.remove(copy)
                    print(f"  [Deleted] {copy}")
                    count += 1
                    bytes_saved += size
                except OSError as e:
                    print(f"  [Error Deleting] {copy}: {e}")
            else:
                print(f"  [Duplicate] {copy}")
        print("")

    if args.delete:
        print(f"Cleanup complete. Deleted {count} files. Recovered {bytes_saved / (1024*1024):.2f} MB.")
    else:
        print("Run with --delete to remove duplicate files (keeps the first occurrence).")

if __name__ == "__main__":
    main()
