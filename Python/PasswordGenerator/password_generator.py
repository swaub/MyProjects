#!/usr/bin/env python3

import random
import string
import sys
import re
from datetime import datetime


class PasswordGenerator:

    LOWERCASE = string.ascii_lowercase
    UPPERCASE = string.ascii_uppercase
    DIGITS = string.digits
    SPECIAL_BASIC = "!@#$%^&*"
    SPECIAL_EXTENDED = "!@#$%^&*()-_=+[]{}|;:,.<>?/~`"

    AMBIGUOUS = "0O1lI|"

    DIFFICULTY_LEVELS = {
        1: {
            "name": "Basic",
            "description": "Lowercase letters only",
            "charset": LOWERCASE,
            "entropy_base": 26
        },
        2: {
            "name": "Simple",
            "description": "Lowercase + Uppercase",
            "charset": LOWERCASE + UPPERCASE,
            "entropy_base": 52
        },
        3: {
            "name": "Standard",
            "description": "Letters + Numbers",
            "charset": LOWERCASE + UPPERCASE + DIGITS,
            "entropy_base": 62
        },
        4: {
            "name": "Strong",
            "description": "Letters + Numbers + Basic Symbols (!@#$%^&*)",
            "charset": LOWERCASE + UPPERCASE + DIGITS + SPECIAL_BASIC,
            "entropy_base": 70
        },
        5: {
            "name": "Maximum",
            "description": "Letters + Numbers + All Special Characters",
            "charset": LOWERCASE + UPPERCASE + DIGITS + SPECIAL_EXTENDED,
            "entropy_base": 94
        }
    }

    def __init__(self, length=16, difficulty=4, exclude_ambiguous=False, count=1):
        self.length = max(4, length)
        self.difficulty = max(1, min(5, difficulty))
        self.exclude_ambiguous = exclude_ambiguous
        self.count = max(1, count)

        self.charset = self.DIFFICULTY_LEVELS[self.difficulty]["charset"]

        if self.exclude_ambiguous:
            self.charset = ''.join(c for c in self.charset if c not in self.AMBIGUOUS)

    def generate(self):
        if self.difficulty == 1:
            return ''.join(random.choice(self.charset) for _ in range(self.length))

        password = []
        remaining_length = self.length

        if self.difficulty >= 2:
            password.append(random.choice([c for c in self.LOWERCASE if c in self.charset]))
            password.append(random.choice([c for c in self.UPPERCASE if c in self.charset]))
            remaining_length -= 2

        if self.difficulty >= 3:
            password.append(random.choice([c for c in self.DIGITS if c in self.charset]))
            remaining_length -= 1

        if self.difficulty >= 4:
            special_chars = self.SPECIAL_BASIC if self.difficulty == 4 else self.SPECIAL_EXTENDED
            available_special = [c for c in special_chars if c in self.charset]
            if available_special:
                password.append(random.choice(available_special))
                remaining_length -= 1

        password.extend(random.choice(self.charset) for _ in range(remaining_length))

        random.shuffle(password)

        return ''.join(password)

    def generate_multiple(self):
        return [self.generate() for _ in range(self.count)]

    @staticmethod
    def calculate_entropy(password):
        charset_size = 0

        if re.search(r'[a-z]', password):
            charset_size += 26
        if re.search(r'[A-Z]', password):
            charset_size += 26
        if re.search(r'[0-9]', password):
            charset_size += 10
        if re.search(r'[^a-zA-Z0-9]', password):
            special_chars = set(c for c in password if not c.isalnum())
            charset_size += len(special_chars) * 5

        if charset_size == 0:
            return 0

        import math
        entropy = len(password) * math.log2(charset_size)
        return entropy

    @staticmethod
    def estimate_crack_time(entropy):
        guesses_per_second = 10_000_000_000
        total_combinations = 2 ** entropy
        seconds = total_combinations / (2 * guesses_per_second)

        if seconds < 1:
            return "Less than 1 second"
        elif seconds < 60:
            return f"{seconds:.1f} seconds"
        elif seconds < 3600:
            return f"{seconds/60:.1f} minutes"
        elif seconds < 86400:
            return f"{seconds/3600:.1f} hours"
        elif seconds < 31536000:
            return f"{seconds/86400:.1f} days"
        elif seconds < 31536000 * 100:
            return f"{seconds/31536000:.1f} years"
        elif seconds < 31536000 * 1000:
            return f"{seconds/31536000:.0f} years"
        elif seconds < 31536000 * 1000000:
            return f"{seconds/(31536000*1000):.1f} thousand years"
        elif seconds < 31536000 * 1000000000:
            return f"{seconds/(31536000*1000000):.1f} million years"
        else:
            return f"{seconds/(31536000*1000000000):.1f} billion years"

    @staticmethod
    def get_strength_rating(entropy):
        if entropy < 28:
            return "Very Weak", "🔴"
        elif entropy < 36:
            return "Weak", "🟠"
        elif entropy < 60:
            return "Fair", "🟡"
        elif entropy < 80:
            return "Strong", "🟢"
        else:
            return "Very Strong", "🔵"

    @staticmethod
    def analyze_password(password):
        entropy = PasswordGenerator.calculate_entropy(password)
        crack_time = PasswordGenerator.estimate_crack_time(entropy)
        strength, emoji = PasswordGenerator.get_strength_rating(entropy)

        has_lower = bool(re.search(r'[a-z]', password))
        has_upper = bool(re.search(r'[A-Z]', password))
        has_digit = bool(re.search(r'[0-9]', password))
        has_special = bool(re.search(r'[^a-zA-Z0-9]', password))

        return {
            "length": len(password),
            "entropy": entropy,
            "crack_time": crack_time,
            "strength": strength,
            "emoji": emoji,
            "composition": {
                "lowercase": has_lower,
                "uppercase": has_upper,
                "digits": has_digit,
                "special": has_special
            }
        }


def display_banner():
    print("=" * 70)
    print(f"{'PASSWORD GENERATOR':^70}")
    print("=" * 70)
    print()


def display_difficulty_options():
    print("\n🔒 Difficulty Levels:")
    print("-" * 70)
    for level, info in PasswordGenerator.DIFFICULTY_LEVELS.items():
        print(f"  {level}. {info['name']:<12} - {info['description']}")
    print("-" * 70)


def get_user_input():
    print("\n⚙️  Password Configuration:")
    print("-" * 70)

    while True:
        try:
            length_input = input("Password length (8-128, default: 16): ").strip()
            if not length_input:
                length = 16
                break
            length = int(length_input)
            if 4 <= length <= 128:
                break
            print("❌ Length must be between 4 and 128")
        except ValueError:
            print("❌ Please enter a valid number")
        except KeyboardInterrupt:
            print("\n\nExiting...")
            sys.exit(0)

    display_difficulty_options()
    while True:
        try:
            diff_input = input("\nSelect difficulty (1-5, default: 4): ").strip()
            if not diff_input:
                difficulty = 4
                break
            difficulty = int(diff_input)
            if 1 <= difficulty <= 5:
                break
            print("❌ Difficulty must be between 1 and 5")
        except ValueError:
            print("❌ Please enter a valid number")
        except KeyboardInterrupt:
            print("\n\nExiting...")
            sys.exit(0)

    while True:
        try:
            ambiguous_input = input("\nExclude ambiguous characters (0O1lI|)? (y/N): ").strip().lower()
            exclude_ambiguous = ambiguous_input in ['y', 'yes']
            break
        except KeyboardInterrupt:
            print("\n\nExiting...")
            sys.exit(0)

    while True:
        try:
            count_input = input("Number of passwords to generate (1-50, default: 1): ").strip()
            if not count_input:
                count = 1
                break
            count = int(count_input)
            if 1 <= count <= 50:
                break
            print("❌ Count must be between 1 and 50")
        except ValueError:
            print("❌ Please enter a valid number")
        except KeyboardInterrupt:
            print("\n\nExiting...")
            sys.exit(0)

    return length, difficulty, exclude_ambiguous, count


def save_to_file(passwords, analyses):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"passwords_{timestamp}.txt"

    try:
        with open(filename, 'w') as f:
            f.write("=" * 70 + "\n")
            f.write(f"{'PASSWORD GENERATOR OUTPUT':^70}\n")
            f.write(f"{'Generated: ' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'):^70}\n")
            f.write("=" * 70 + "\n\n")

            for i, (password, analysis) in enumerate(zip(passwords, analyses), 1):
                f.write(f"Password #{i}:\n")
                f.write(f"  {password}\n\n")
                f.write(f"  Length: {analysis['length']} characters\n")
                f.write(f"  Entropy: {analysis['entropy']:.1f} bits\n")
                f.write(f"  Strength: {analysis['strength']}\n")
                f.write(f"  Estimated Crack Time: {analysis['crack_time']}\n")
                f.write(f"  Composition: ", )
                comp = []
                if analysis['composition']['lowercase']:
                    comp.append("Lowercase")
                if analysis['composition']['uppercase']:
                    comp.append("Uppercase")
                if analysis['composition']['digits']:
                    comp.append("Digits")
                if analysis['composition']['special']:
                    comp.append("Special")
                f.write(", ".join(comp) + "\n")
                f.write("\n" + "-" * 70 + "\n\n")

        print(f"\n✅ Passwords saved to: {filename}")
        return True
    except Exception as e:
        print(f"\n❌ Error saving to file: {e}")
        return False


def main():
    display_banner()

    length, difficulty, exclude_ambiguous, count = get_user_input()

    generator = PasswordGenerator(
        length=length,
        difficulty=difficulty,
        exclude_ambiguous=exclude_ambiguous,
        count=count
    )

    print("\n" + "=" * 70)
    print(f"{'GENERATED PASSWORDS':^70}")
    print("=" * 70)

    difficulty_info = PasswordGenerator.DIFFICULTY_LEVELS[difficulty]
    print(f"\nConfiguration:")
    print(f"  Length: {length} characters")
    print(f"  Difficulty: {difficulty_info['name']} - {difficulty_info['description']}")
    print(f"  Exclude Ambiguous: {'Yes' if exclude_ambiguous else 'No'}")
    print(f"  Count: {count}")
    print("\n" + "-" * 70 + "\n")

    passwords = generator.generate_multiple()
    analyses = [PasswordGenerator.analyze_password(pwd) for pwd in passwords]

    for i, (password, analysis) in enumerate(zip(passwords, analyses), 1):
        print(f"Password #{i}:")
        print(f"  {password}")
        print(f"\n  📊 Analysis:")
        print(f"     Length: {analysis['length']} characters")
        print(f"     Entropy: {analysis['entropy']:.1f} bits")
        print(f"     Strength: {analysis['emoji']} {analysis['strength']}")
        print(f"     Estimated Crack Time: {analysis['crack_time']}")

        print(f"\n  📝 Composition:")
        if analysis['composition']['lowercase']:
            print("     ✓ Lowercase letters")
        if analysis['composition']['uppercase']:
            print("     ✓ Uppercase letters")
        if analysis['composition']['digits']:
            print("     ✓ Numbers")
        if analysis['composition']['special']:
            print("     ✓ Special characters")

        if i < len(passwords):
            print("\n" + "-" * 70 + "\n")

    print("\n" + "=" * 70)
    try:
        save_choice = input("\n💾 Save passwords to file? (y/N): ").strip().lower()
        if save_choice in ['y', 'yes']:
            save_to_file(passwords, analyses)
    except KeyboardInterrupt:
        pass

    print("\n" + "=" * 70)
    print("Thank you for using Password Generator!")
    print("=" * 70 + "\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nExiting...")
        sys.exit(0)
