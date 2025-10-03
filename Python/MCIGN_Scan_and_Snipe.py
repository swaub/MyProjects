import random
import requests
import time
import aiohttp
import asyncio
import json
from datetime import datetime, timedelta

class MinecraftIGN:
    def __init__(self):
        self.available_igns = []
        self.auth_data = {}

    def scan_usernames(self):
        """Scan for available Minecraft usernames"""
        print("\n=== USERNAME SCANNER ===")
        N = int(input("How many characters should the IGN have (3-16): "))
        if N < 3 or N > 16:
            print("Invalid length! Minecraft usernames must be between 3 and 16 characters.")
            return

        tries = int(input("How many IGNs would you like to check: "))
        checked_count = 0

        print(f"\nScanning {tries} usernames of length {N}...")
        print("Note: Longer delays between checks to avoid rate limiting.\n")

        rate_limit_count = 0

        while checked_count < tries:
            # Adaptive delay - increase if we're getting rate limited
            if rate_limit_count > 3:
                time.sleep(3)  # Longer delay if hitting rate limits
            elif rate_limit_count > 1:
                time.sleep(1.5)
            else:
                time.sleep(0.8)  # Slightly longer base delay

            ran_str = ''.join(random.choices('abcdefghijklmnopqrstuvwxyz1234567890_', k=N))

            # Check if a UUID exists for this username
            url = f'https://api.mojang.com/users/profiles/minecraft/{ran_str}'

            try:
                response = requests.get(url, timeout=5)

                # If status 200 and has content, name is TAKEN
                if response.status_code == 200:
                    try:
                        data = response.json()
                        if data and 'id' in data:
                            print(f"{ran_str} is NOT available (taken by player).")
                        else:
                            print(f"{ran_str} is NOT available (registered).")
                    except:
                        print(f"{ran_str} is NOT available (taken).")

                # If 204 or 404, name MIGHT be available
                elif response.status_code == 204 or response.status_code == 404:
                    print(f"✓ AVAILABLE IGN found! {ran_str}")
                    self.available_igns.append(ran_str)
                    rate_limit_count = 0  # Reset rate limit counter on success

                # Rate limiting
                elif response.status_code == 429:
                    rate_limit_count += 1
                    print(f"{ran_str} - Rate limited (#{rate_limit_count}), adjusting delay...")
                    time.sleep(3)
                    checked_count -= 1
                else:
                    print(f"{ran_str} - Unknown status: {response.status_code}")

            except requests.exceptions.RequestException as e:
                print(f"{ran_str} - Request failed: {e}")

            checked_count += 1

        # Show results
        print(f"\n{'='*40}")
        print(f"Finished checking {tries} usernames.")
        if self.available_igns:
            print(f"Found {len(self.available_igns)} AVAILABLE username(s):")
            for i, ign in enumerate(self.available_igns, 1):
                print(f"  {i}. {ign}")
            return True
        else:
            print("Sorry, no available IGNs found :(")
            return False

    def setup_sniper(self):
        """Setup authentication for sniping"""
        print("\n=== SNIPER SETUP ===")
        print("To snipe usernames, you need your Minecraft account credentials.")
        print("Note: Bearer token can be obtained from your Minecraft launcher.")

        self.auth_data['uuid'] = input("Enter your UUID: ")
        self.auth_data['bearer_key'] = input("Enter your Bearer Key: ")
        self.auth_data['password'] = input("Enter your account password: ")

        print("\n✓ Authentication configured!")

    async def snipe_username(self, target_ign, drop_time=None):
        """Attempt to claim a username"""
        auth = "Bearer " + self.auth_data['bearer_key']

        if drop_time:
            print(f"⏰ Waiting until {drop_time} to snipe {target_ign}...")
            while True:
                now = datetime.now()
                current_time = now.strftime("%H:%M:%S")
                if current_time >= drop_time:
                    break
                await asyncio.sleep(0.1)

        print(f"🎯 Attempting to snipe {target_ign}...")

        async with aiohttp.ClientSession() as session:
            async with session.post(
                f'https://api.mojang.com/user/profile/{self.auth_data["uuid"]}/name',
                headers={'Authorization': auth},
                json={"name": target_ign, "password": self.auth_data['password']}
            ) as resp:
                status = resp.status
                response_text = await resp.text()

        if status == 204:
            print(f"✅ SUCCESS! {target_ign} has been claimed!")
            return True
        else:
            print(f"❌ Failed to claim {target_ign}. Status: {status}")
            if response_text:
                print(f"Response: {response_text}")
            return False

    def save_results(self):
        """Save found usernames to a file"""
        if not self.available_igns:
            print("No usernames to save.")
            return

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"available_igns_{timestamp}.txt"

        with open(filename, 'w') as f:
            f.write(f"Available Minecraft IGNs - Found at {datetime.now()}\n")
            f.write("="*50 + "\n\n")
            for ign in self.available_igns:
                f.write(f"{ign}\n")

        print(f"✓ Results saved to {filename}")

async def main():
    tool = MinecraftIGN()

    while True:
        print("\n" + "="*50)
        print("MINECRAFT IGN SCANNER & SNIPER")
        print("="*50)
        print("1. Scan for available usernames")
        print("2. Setup sniper credentials")
        print("3. Snipe from found usernames")
        print("4. Manually enter username to snipe")
        print("5. Save results to file")
        print("6. Exit")

        choice = input("\nSelect option (1-6): ")

        if choice == "1":
            tool.scan_usernames()

        elif choice == "2":
            tool.setup_sniper()

        elif choice == "3":
            if not tool.available_igns:
                print("No available usernames found. Run a scan first!")
                continue

            if not tool.auth_data:
                print("Authentication not configured. Please setup sniper first (option 2).")
                continue

            print("\nAvailable usernames:")
            for i, ign in enumerate(tool.available_igns, 1):
                print(f"  {i}. {ign}")

            try:
                selection = int(input("\nSelect username number to snipe: ")) - 1
                if 0 <= selection < len(tool.available_igns):
                    target = tool.available_igns[selection]

                    print(f"\nSelected: {target}")
                    print("Options:")
                    print("1. Snipe immediately")
                    print("2. Schedule snipe for specific time")

                    timing = input("Select timing (1-2): ")

                    if timing == "1":
                        await tool.snipe_username(target)
                    elif timing == "2":
                        drop_time = input("Enter drop time (HH:MM:SS): ")
                        await tool.snipe_username(target, drop_time)

                    # Remove from available list after attempting
                    tool.available_igns.remove(target)
                else:
                    print("Invalid selection!")
            except ValueError:
                print("Invalid input!")

        elif choice == "4":
            if not tool.auth_data:
                print("Authentication not configured. Please setup sniper first (option 2).")
                continue

            target = input("Enter username to snipe: ")
            print("Options:")
            print("1. Snipe immediately")
            print("2. Schedule snipe for specific time")

            timing = input("Select timing (1-2): ")

            if timing == "1":
                await tool.snipe_username(target)
            elif timing == "2":
                drop_time = input("Enter drop time (HH:MM:SS): ")
                await tool.snipe_username(target, drop_time)

        elif choice == "5":
            tool.save_results()

        elif choice == "6":
            print("\nGoodbye!")
            break

        else:
            print("Invalid option!")

if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\nProgram interrupted. Goodbye!")