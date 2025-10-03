#!/usr/bin/env python3
"""
Bandwidth Monitor - Real-time network traffic monitoring utility
Monitors upload/download speeds and total data transferred across network interfaces
"""

import psutil
import time
import sys
import os
from datetime import datetime


class BandwidthMonitor:
    def __init__(self, interface=None, refresh_interval=1):
        """
        Initialize the bandwidth monitor

        Args:
            interface (str): Specific network interface to monitor (None for all)
            refresh_interval (float): Update interval in seconds
        """
        self.interface = interface
        self.refresh_interval = refresh_interval
        self.start_time = datetime.now()

    @staticmethod
    def get_interfaces():
        """Get list of available network interfaces"""
        stats = psutil.net_io_counters(pernic=True)
        return list(stats.keys())

    @staticmethod
    def format_bytes(bytes_value):
        """Convert bytes to human-readable format"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if bytes_value < 1024.0:
                return f"{bytes_value:.2f} {unit}"
            bytes_value /= 1024.0
        return f"{bytes_value:.2f} PB"

    @staticmethod
    def format_speed(bytes_per_sec):
        """Convert bytes per second to human-readable format"""
        for unit in ['B/s', 'KB/s', 'MB/s', 'GB/s']:
            if bytes_per_sec < 1024.0:
                return f"{bytes_per_sec:.2f} {unit}"
            bytes_per_sec /= 1024.0
        return f"{bytes_per_sec:.2f} TB/s"

    def clear_screen(self):
        """Clear the terminal screen"""
        os.system('cls' if os.name == 'nt' else 'clear')

    def get_network_stats(self):
        """Get current network statistics"""
        if self.interface:
            stats = psutil.net_io_counters(pernic=True)
            if self.interface in stats:
                return stats[self.interface]
            else:
                print(f"Interface '{self.interface}' not found!")
                sys.exit(1)
        else:
            return psutil.net_io_counters()

    def monitor(self):
        """Start monitoring bandwidth"""
        print("Bandwidth Monitor Started")
        print("=" * 60)

        if self.interface:
            print(f"Monitoring interface: {self.interface}")
        else:
            print("Monitoring all interfaces")

        print(f"Refresh interval: {self.refresh_interval}s")
        print("\nPress Ctrl+C to stop\n")
        time.sleep(2)

        # Get initial stats
        prev_stats = self.get_network_stats()
        prev_time = time.time()

        # Track totals since start
        total_sent_start = prev_stats.bytes_sent
        total_recv_start = prev_stats.bytes_recv

        try:
            while True:
                time.sleep(self.refresh_interval)

                # Get current stats
                curr_stats = self.get_network_stats()
                curr_time = time.time()

                # Calculate time difference
                time_diff = curr_time - prev_time

                # Calculate bytes transferred
                bytes_sent = curr_stats.bytes_sent - prev_stats.bytes_sent
                bytes_recv = curr_stats.bytes_recv - prev_stats.bytes_recv

                # Calculate speeds
                upload_speed = bytes_sent / time_diff
                download_speed = bytes_recv / time_diff

                # Calculate totals since start
                total_sent = curr_stats.bytes_sent - total_sent_start
                total_recv = curr_stats.bytes_recv - total_recv_start

                # Calculate session duration
                duration = datetime.now() - self.start_time
                hours, remainder = divmod(duration.seconds, 3600)
                minutes, seconds = divmod(remainder, 60)

                # Display stats
                self.clear_screen()
                print("=" * 60)
                print(f"{'BANDWIDTH MONITOR':^60}")
                print("=" * 60)

                if self.interface:
                    print(f"Interface: {self.interface}")
                else:
                    print("Interface: All")

                print(f"Session Duration: {hours:02d}:{minutes:02d}:{seconds:02d}")
                print(f"Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
                print("-" * 60)

                print("\n📊 CURRENT SPEEDS:")
                print(f"  ↑ Upload:   {self.format_speed(upload_speed):>15}")
                print(f"  ↓ Download: {self.format_speed(download_speed):>15}")
                print(f"  ⇅ Total:    {self.format_speed(upload_speed + download_speed):>15}")

                print("\n📈 SESSION TOTALS:")
                print(f"  ↑ Uploaded:   {self.format_bytes(total_sent):>15}")
                print(f"  ↓ Downloaded: {self.format_bytes(total_recv):>15}")
                print(f"  ⇅ Combined:   {self.format_bytes(total_sent + total_recv):>15}")

                print("\n📦 PACKETS:")
                print(f"  Sent:     {curr_stats.packets_sent:>15,}")
                print(f"  Received: {curr_stats.packets_recv:>15,}")

                if hasattr(curr_stats, 'errin') and hasattr(curr_stats, 'errout'):
                    print("\n⚠️  ERRORS:")
                    print(f"  In:  {curr_stats.errin:>15,}")
                    print(f"  Out: {curr_stats.errout:>15,}")

                if hasattr(curr_stats, 'dropin') and hasattr(curr_stats, 'dropout'):
                    print("\n❌ DROPS:")
                    print(f"  In:  {curr_stats.dropin:>15,}")
                    print(f"  Out: {curr_stats.dropout:>15,}")

                print("\n" + "=" * 60)
                print("Press Ctrl+C to stop monitoring")

                # Update previous stats
                prev_stats = curr_stats
                prev_time = curr_time

        except KeyboardInterrupt:
            print("\n\n" + "=" * 60)
            print("Monitoring stopped")
            print("=" * 60)

            # Final statistics
            final_stats = self.get_network_stats()
            duration = datetime.now() - self.start_time
            total_seconds = duration.total_seconds()

            total_sent = final_stats.bytes_sent - total_sent_start
            total_recv = final_stats.bytes_recv - total_recv_start

            print("\n📊 FINAL SESSION STATISTICS:")
            print(f"  Duration: {duration}")
            print(f"  Total Uploaded: {self.format_bytes(total_sent)}")
            print(f"  Total Downloaded: {self.format_bytes(total_recv)}")
            print(f"  Total Combined: {self.format_bytes(total_sent + total_recv)}")

            if total_seconds > 0:
                avg_upload = total_sent / total_seconds
                avg_download = total_recv / total_seconds
                print(f"\n  Average Upload Speed: {self.format_speed(avg_upload)}")
                print(f"  Average Download Speed: {self.format_speed(avg_download)}")

            print("\n" + "=" * 60)
            sys.exit(0)


def main():
    """Main function"""
    print("=" * 60)
    print(f"{'BANDWIDTH MONITOR':^60}")
    print("=" * 60)

    # Get available interfaces
    interfaces = BandwidthMonitor.get_interfaces()

    print("\nAvailable Network Interfaces:")
    print("-" * 60)
    for i, interface in enumerate(interfaces, 1):
        print(f"  {i}. {interface}")
    print(f"  {len(interfaces) + 1}. Monitor all interfaces")
    print("-" * 60)

    # Interface selection
    while True:
        try:
            choice = input("\nSelect interface (or press Enter for all): ").strip()

            if not choice:
                selected_interface = None
                break

            choice_num = int(choice)
            if 1 <= choice_num <= len(interfaces):
                selected_interface = interfaces[choice_num - 1]
                break
            elif choice_num == len(interfaces) + 1:
                selected_interface = None
                break
            else:
                print(f"Invalid choice. Please select 1-{len(interfaces) + 1}")
        except ValueError:
            print("Invalid input. Please enter a number.")
        except KeyboardInterrupt:
            print("\nExiting...")
            sys.exit(0)

    # Refresh interval selection
    while True:
        try:
            interval_input = input("\nRefresh interval in seconds (default: 1): ").strip()

            if not interval_input:
                refresh_interval = 1.0
                break

            refresh_interval = float(interval_input)
            if refresh_interval <= 0:
                print("Interval must be positive")
                continue
            break
        except ValueError:
            print("Invalid input. Please enter a number.")
        except KeyboardInterrupt:
            print("\nExiting...")
            sys.exit(0)

    # Start monitoring
    monitor = BandwidthMonitor(interface=selected_interface, refresh_interval=refresh_interval)
    monitor.monitor()


if __name__ == "__main__":
    main()
