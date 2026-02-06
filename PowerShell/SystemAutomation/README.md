# System Automation Scripts (PowerShell)

A collection of useful PowerShell scripts to automate system maintenance and organization.

## 🛠️ Included Tools

### 1. [Lazy-Organizer.ps1](./Lazy-Organizer.ps1)
Automatically sorts files in the current directory into categorized folders (Images, Documents, Code, etc.) based on their extensions.
*   **Safe:** Renames duplicate files instead of overwriting them.

### 2. [Net-Fixer.ps1](./Net-Fixer.ps1)
A "one-click" repair utility for network issues. It flushes DNS, renews your IP, and resets the network stack.
*   **Requirements:** Windows OS, Administrator privileges.

### 3. [Wifi-Revealer.ps1](./Wifi-Revealer.ps1)
Retrieves a list of all saved Wi-Fi profiles on the system and decrypts their passwords (Key Content).
*   **Usage:** Run as Administrator for best results.

## 🚀 How to Run

1.  Open PowerShell in this directory.
2.  Execute a script:
    ```powershell
    .\Lazy-Organizer.ps1
    ```
3.  If you encounter an "Execution Policy" error, run this command first:
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    ```

## 📄 License
MIT License.
