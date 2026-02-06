# LogParser

A high-performance Java CLI tool to filter massive log files by severity (ERROR, WARN, INFO) efficiently.

## 🚀 Usage

### Option 1: Run Runnable JAR (Recommended)
```bash
java -jar LogParser.jar
```
Follow the interactive prompts to enter the file path and severity filter.

### Option 2: Run from Source
1.  Navigate to `src`.
2.  Compile and run:
    ```bash
    javac com/swaub/logparser/LogParser.java
    java com.swaub.logparser.LogParser
    ```

## ⚡ Performance
*   Uses `BufferedReader` for memory-efficient streaming.
*   Optimized case-insensitive matching to handle GB-sized logs without memory spikes.

## 🛠️ Compilation
To rebuild the JAR:
```bash
mkdir -p bin
javac -d bin src/com/swaub/logparser/LogParser.java
echo "Main-Class: com.swaub.logparser.LogParser" > Manifest.txt
jar cfm LogParser.jar Manifest.txt -C bin .
```
