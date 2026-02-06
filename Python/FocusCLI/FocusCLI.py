import time
import argparse
import sys
import os

# Try to import a notification library, or fallback to simple print
try:
    from plyer import notification
    HAS_NOTIFY = True
except ImportError:
    HAS_NOTIFY = False

def notify(title, message):
    """Sends a desktop notification if plyer is installed."""
    if HAS_NOTIFY:
        try:
            notification.notify(
                title=title,
                message=message,
                app_name='FocusCLI',
                timeout=10
            )
        except:
            pass
    # Always print to console
    print(f"\n[{title}] {message}\a") # \a is terminal bell

def timer(minutes, label):
    """Runs a countdown timer."""
    seconds = minutes * 60
    total = seconds
    
    print(f"--- Starting {label}: {minutes} minutes ---")
    
    try:
        while seconds > 0:
            mins, secs = divmod(seconds, 60)
            timer_display = f"{mins:02d}:{secs:02d}"
            
            # Print on same line
            sys.stdout.write(f"\r⏳ {label}: {timer_display} remaining...  ")
            sys.stdout.flush()
            
            time.sleep(1)
            seconds -= 1
            
        sys.stdout.write(f"\r✅ {label}: 00:00 - Done!                 \n")
        return True
        
    except KeyboardInterrupt:
        print(f"\n⛔ {label} cancelled.")
        return False

def main():
    parser = argparse.ArgumentParser(description="FocusCLI: A simple Pomodoro timer.")
    parser.add_argument("-w", "--work", type=int, default=25, help="Work duration in minutes (default: 25)")
    parser.add_argument("-b", "--break-time", type=int, default=5, help="Short break duration in minutes (default: 5)")
    parser.add_argument("-l", "--long-break", type=int, default=15, help="Long break duration in minutes (default: 15)")
    parser.add_argument("-c", "--cycles", type=int, default=4, help="Number of cycles before long break (default: 4)")
    
    args = parser.parse_args()
    
    print("🍅 FocusCLI - Stay Productive!")
    print(f"Configuration: Work={args.work}m, Break={args.break_time}m, Long Break={args.long_break}m")
    print("Press Ctrl+C to stop anytime.\n")
    
    cycle = 1
    try:
        while True:
            print(f"Cycle {cycle}/{args.cycles}")
            
            # Work Phase
            notify("FocusCLI", "Time to focus! Start working.")
            if not timer(args.work, "Focus"): break
            
            # Break Phase
            if cycle % args.cycles == 0:
                notify("FocusCLI", "Great job! Take a long break.")
                if not timer(args.long_break, "Long Break"): break
            else:
                notify("FocusCLI", "Break time! Stretch your legs.")
                if not timer(args.break_time, "Short Break"): break
            
            cycle += 1
            
    except KeyboardInterrupt:
        print("\nGoodbye!")

if __name__ == "__main__":
    main()
