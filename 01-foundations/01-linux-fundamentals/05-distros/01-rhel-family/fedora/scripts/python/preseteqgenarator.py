import os
import sys
import subprocess
import json
import time
import shutil
import glob
import datetime
import threading
import urllib.request
import urllib.error
import hashlib

# Configuration
HOME = os.path.expanduser("~")
TARGET_DIR = os.path.join(
    HOME, ".var/app/com.github.wwmm.easyeffects/config/easyeffects/output"
)

# Colors
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
NC = "\033[0m"

# Global variable to track backup location
LATEST_BACKUP_DIR = None

# Presets Data
PRESETS = [
    {
        "name": "Movies_Cinematic",
        "loudness": -3.0,
        "low_freq": 50.0,
        "low_gain": 6.5,
        "mid_freq": 440.0,
        "mid_gain": -8.0,
        "high_freq": 20000.0,
        "high_gain": 4.0,
    },
    {
        "name": "TV_Clear_Dialogue",
        "loudness": -1.5,
        "low_freq": 50.0,
        "low_gain": 1.0,
        "mid_freq": 440.0,
        "mid_gain": 3.5,
        "high_freq": 20000.0,
        "high_gain": 2.0,
    },
    {
        "name": "Music_Bass_Boost",
        "loudness": -5.0,
        "low_freq": 50.0,
        "low_gain": 7.0,
        "mid_freq": 440.0,
        "mid_gain": -1.5,
        "high_freq": 20000.0,
        "high_gain": 2.5,
    },
    {
        "name": "Music_Bright",
        "loudness": -6.0,
        "low_freq": 50.0,
        "low_gain": 0.0,
        "mid_freq": 440.0,
        "mid_gain": 2.0,
        "high_freq": 20000.0,
        "high_gain": 5.5,
    },
    {
        "name": "Gaming_FPS",
        "loudness": -4.0,
        "low_freq": 50.0,
        "low_gain": -2.0,
        "mid_freq": 440.0,
        "mid_gain": 4.5,
        "high_freq": 20000.0,
        "high_gain": 6.0,
    },
    {
        "name": "Night_Listening",
        "loudness": -8.0,
        "low_freq": 50.0,
        "low_gain": -5.0,
        "mid_freq": 440.0,
        "mid_gain": 0.0,
        "high_freq": 20000.0,
        "high_gain": -2.0,
    },
    {
        "name": "Music_HipHop_Punchy",
        "loudness": -4.0,
        "low_freq": 60.0,
        "low_gain": 5.5,
        "mid_freq": 440.0,
        "mid_gain": 1.0,
        "high_freq": 20000.0,
        "high_gain": 2.0,
    },
    {
        "name": "Music_Rock_Metal",
        "loudness": -3.0,
        "low_freq": 50.0,
        "low_gain": 3.0,
        "mid_freq": 440.0,
        "mid_gain": 0.0,
        "high_freq": 20000.0,
        "high_gain": 4.5,
    },
    {
        "name": "Music_Pop_Vocal",
        "loudness": -3.0,
        "low_freq": 50.0,
        "low_gain": 1.5,
        "mid_freq": 440.0,
        "mid_gain": 3.0,
        "high_freq": 20000.0,
        "high_gain": 3.0,
    },
    {
        "name": "Podcast_Interview",
        "loudness": -2.0,
        "low_freq": 80.0,
        "low_gain": -2.0,
        "mid_freq": 1000.0,
        "mid_gain": 5.0,
        "high_freq": 20000.0,
        "high_gain": 1.0,
    },
    {
        "name": "Music_Electronic",
        "loudness": -2.0,
        "low_freq": 50.0,
        "low_gain": 6.0,
        "mid_freq": 440.0,
        "mid_gain": -1.0,
        "high_freq": 20000.0,
        "high_gain": 4.0,
    },
    {
        "name": "Music_Acoustic",
        "loudness": -3.0,
        "low_freq": 50.0,
        "low_gain": 1.0,
        "mid_freq": 440.0,
        "mid_gain": 4.0,
        "high_freq": 20000.0,
        "high_gain": 2.0,
    },
    {
        "name": "Vocal_Boost_Call",
        "loudness": -1.0,
        "low_freq": 100.0,
        "low_gain": -4.0,
        "mid_freq": 1500.0,
        "mid_gain": 6.0,
        "high_freq": 20000.0,
        "high_gain": 1.0,
    },
    {
        "name": "Laptop_Speaker_Fix",
        "loudness": -1.0,
        "low_freq": 50.0,
        "low_gain": -2.0,
        "mid_freq": 440.0,
        "mid_gain": 3.0,
        "high_freq": 20000.0,
        "high_gain": 5.0,
    },
    {
        "name": "Flat_Response",
        "loudness": 0.0,
        "low_freq": 50.0,
        "low_gain": 0.0,
        "mid_freq": 440.0,
        "mid_gain": 0.0,
        "high_freq": 20000.0,
        "high_gain": 0.0,
    },
    {
        "name": "Movie_Dialogue_Boost",
        "loudness": -2.0,
        "low_freq": 60.0,
        "low_gain": -4.0,
        "mid_freq": 1200.0,
        "mid_gain": 5.0,
        "high_freq": 20000.0,
        "high_gain": 3.0,
    },
]


def run_cmd(cmd, check=True, capture_output=True):
    """Helper to run shell commands."""
    return subprocess.run(
        cmd, shell=True, check=check, capture_output=capture_output, text=True
    )


def check_dependencies():
    if shutil.which("flatpak") is None:
        print(
            f"{RED}Error: flatpak is not installed or not in PATH.{NC}", file=sys.stderr
        )
        sys.exit(1)


def check_easyeffects():
    try:
        run_cmd("flatpak info com.github.wwmm.easyeffects")
    except subprocess.CalledProcessError:
        print(f"{YELLOW}EasyEffects is not installed.{NC}")
        choice = input("Install it now via Flatpak? (y/n) ").strip().lower()
        if choice == "y":
            run_cmd(
                "flatpak install -y com.github.wwmm.easyeffects",
                check=True,
                capture_output=False,
            )
        else:
            print(f"{RED}EasyEffects is required. Exiting.{NC}", file=sys.stderr)
            sys.exit(1)


def generate_preset_file(p):
    """Generates the JSON preset file."""
    data = {
        "output": {
            "bass_loudness#0": {
                "bypass": False,
                "input-gain": 0.0,
                "link": -9.0,
                "loudness": float(p["loudness"]),
                "output": -7.0,
                "output-gain": 0.0,
            },
            "blocklist": [],
            "equalizer#0": {
                "balance": 0.0,
                "bypass": False,
                "input-gain": 0.0,
                "left": {
                    "band0": {
                        "frequency": float(p["low_freq"]),
                        "gain": float(p["low_gain"]),
                        "mode": "RLC (BT)",
                        "type": "Bell",
                        "q": 4.36,
                        "width": 4.0,
                    },
                    "band5": {
                        "frequency": float(p["mid_freq"]),
                        "gain": float(p["mid_gain"]),
                        "mode": "RLC (BT)",
                        "type": "Bell",
                        "q": 4.36,
                        "width": 4.0,
                    },
                    "band14": {
                        "frequency": float(p["high_freq"]),
                        "gain": float(p["high_gain"]),
                        "mode": "RLC (BT)",
                        "type": "Bell",
                        "q": 4.36,
                        "width": 4.0,
                    },
                },
                "right": {
                    "band0": {
                        "frequency": float(p["low_freq"]),
                        "gain": float(p["low_gain"]),
                        "mode": "RLC (BT)",
                        "type": "Bell",
                        "q": 4.36,
                        "width": 4.0,
                    },
                    "band5": {
                        "frequency": float(p["mid_freq"]),
                        "gain": float(p["mid_gain"]),
                        "mode": "RLC (BT)",
                        "type": "Bell",
                        "q": 4.36,
                        "width": 4.0,
                    },
                    "band14": {
                        "frequency": float(p["high_freq"]),
                        "gain": float(p["high_gain"]),
                        "mode": "RLC (BT)",
                        "type": "Bell",
                        "q": 4.36,
                        "width": 4.0,
                    },
                },
                "mode": "IIR",
                "num-bands": 15,
                "output-gain": 0.0,
                "split-channels": False,
            },
            "maximizer#0": {
                "bypass": False,
                "input-gain": 0.0,
                "output-gain": 0.0,
                "release": 25.0,
                "threshold": 0.0,
            },
            "plugins_order": ["bass_loudness#0", "equalizer#0", "maximizer#0"],
        }
    }

    filepath = os.path.join(TARGET_DIR, f"{p['name']}.json")
    with open(filepath, "w") as f:
        json.dump(data, f, indent=4)


def spinner_task(stop_event):
    """Runs a spinner animation in a separate thread."""
    spinstr = "|/-\\"
    while not stop_event.is_set():
        for char in spinstr:
            if stop_event.is_set():
                break
            sys.stdout.write(f"[{char}]")
            sys.stdout.flush()
            time.sleep(0.1)
            sys.stdout.write("\b\b\b")
    sys.stdout.write("   \b\b\b")
    sys.stdout.flush()


def optimize_fedora(args):
    """Checks for Fedora and offers PipeWire optimization."""
    if args:
        return  # Only run if no args provided (setup mode)

    if not os.path.exists("/etc/os-release"):
        return
    with open("/etc/os-release") as f:
        if "fedora" not in f.read().lower():
            return

    print(f"{BLUE}Checking System Audio (PipeWire) configuration...{NC}")
    pw_conf_dir = os.path.join(HOME, ".config/pipewire/pipewire.conf.d")
    pw_conf_file = os.path.join(pw_conf_dir, "99-high-quality.conf")

    try:
        subprocess.run(
            ["pgrep", "-x", "pipewire"], check=True, stdout=subprocess.DEVNULL
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return

    if not os.path.exists(pw_conf_file):
        print(f"{YELLOW}Fedora/PipeWire Optimization:{NC}")
        print("  Enable higher sample rates (48k/96k) and optimized quantum?")
        choice = input("  Apply? (y/n) ").strip().lower()
        if choice == "y":
            os.makedirs(pw_conf_dir, exist_ok=True)
            config_content = """context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
    default.clock.quantum = 1024
    default.clock.min-quantum = 32
    default.clock.max-quantum = 2048
}
"""
            with open(pw_conf_file, "w") as f:
                f.write(config_content)
            print(f"{GREEN}Config created. Restart PipeWire to apply.{NC}")


def backup_presets():
    """Backs up existing JSON files in the target directory."""
    global LATEST_BACKUP_DIR
    files = glob.glob(os.path.join(TARGET_DIR, "*.json"))
    if files:
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = os.path.join(
            os.path.dirname(TARGET_DIR), f"presets_backup_{timestamp}"
        )
        os.makedirs(backup_dir, exist_ok=True)
        LATEST_BACKUP_DIR = backup_dir
        for f in files:
            shutil.copy(f, backup_dir)
        print(f"{GREEN}Backed up existing presets to:{NC} {backup_dir}")


def cleanup_backups():
    """Removes backups older than 7 days."""
    parent_dir = os.path.dirname(TARGET_DIR)
    now = time.time()
    cutoff = now - (7 * 86400)  # 7 days in seconds
    for item in os.listdir(parent_dir):
        if item.startswith("presets_backup_"):
            path = os.path.join(parent_dir, item)
            if os.path.isdir(path):
                if os.path.getmtime(path) < cutoff:
                    shutil.rmtree(path)


def check_active_diff(generated_names):
    """Compares the currently active preset with the newly generated one."""
    try:
        res = run_cmd(
            "flatpak run --command=gsettings com.github.wwmm.easyeffects get com.github.wwmm.easyeffects last-loaded-preset"
        )
        active_name = res.stdout.strip().replace("'", "")
    except:
        return

    if not active_name:
        return

    if active_name in generated_names and LATEST_BACKUP_DIR:
        old_file = os.path.join(LATEST_BACKUP_DIR, f"{active_name}.json")
        new_file = os.path.join(TARGET_DIR, f"{active_name}.json")

        if os.path.exists(old_file) and os.path.exists(new_file):
            # Use system diff for colored output if available
            try:
                print()
                print(
                    f"{YELLOW}Changes detected in active preset ('{active_name}'):{NC}"
                )
                subprocess.run(
                    ["diff", "-u", "--color=always", old_file, new_file], check=False
                )
            except FileNotFoundError:
                try:
                    subprocess.run(["diff", "-u", old_file, new_file], check=False)
                except FileNotFoundError:
                    print(f"{RED}diff utility not found. Cannot compare files.{NC}")


def download_preset(url, expected_checksum=None):
    """Downloads a preset or list of presets from a URL."""
    print(f"{BLUE}Attempting to download from: {url}{NC}")
    saved_names = []
    try:
        req = urllib.request.Request(
            url, data=None, headers={"User-Agent": "Mozilla/5.0 (PresetGenerator)"}
        )
        with urllib.request.urlopen(req) as response:
            content_bytes = response.read()

        if expected_checksum:
            print(f"{BLUE}Verifying checksum...{NC}")
            # Auto-detect algorithm based on length (32=MD5, 64=SHA256)
            if len(expected_checksum) == 32:
                hasher = hashlib.md5()
                algo_name = "MD5"
            else:
                hasher = hashlib.sha256()
                algo_name = "SHA256"

            hasher.update(content_bytes)
            calculated_hash = hasher.hexdigest()

            if calculated_hash.lower() != expected_checksum.lower():
                print(f"{RED}Error: Checksum mismatch ({algo_name})!{NC}")
                print(f"  Expected: {expected_checksum}")
                print(f"  Actual:   {calculated_hash}")
                return []
            print(f"{GREEN}Checksum verified ({algo_name}).{NC}")

        content = content_bytes.decode("utf-8")

        try:
            data = json.loads(content)
        except json.JSONDecodeError:
            print(f"{RED}Error: The content at the URL is not valid JSON.{NC}")
            return []

        # Case 1: Raw EasyEffects preset
        if isinstance(data, dict) and ("output" in data or "input" in data):
            filename = url.rstrip("/").split("/")[-1]
            if not filename.lower().endswith(".json"):
                filename = "downloaded_preset.json"

            preset_name = os.path.splitext(filename)[0]
            filepath = os.path.join(TARGET_DIR, filename)

            with open(filepath, "w") as f:
                json.dump(data, f, indent=4)
            print(f"{GREEN}Saved preset: {filename}{NC}")
            saved_names.append(preset_name)

        # Case 2: List of definitions
        elif isinstance(data, list):
            print(f"{BLUE}Detected preset list. Generating...{NC}")
            for p in data:
                if "name" in p and "loudness" in p:
                    try:
                        generate_preset_file(p)
                        print(f"  - Generated: {CYAN}{p['name']}{NC}")
                        saved_names.append(p["name"])
                    except Exception as e:
                        print(f"  - {RED}Failed: {p.get('name')} ({e}){NC}")
        else:
            print(f"{RED}Error: Unrecognized JSON format.{NC}")

    except Exception as e:
        print(f"{RED}Download failed: {e}{NC}")

    return saved_names


def main():
    # Parse Arguments
    args = sys.argv[1:]
    if "-h" in args or "--help" in args:
        print(f"{GREEN}Usage:{NC} {os.path.basename(sys.argv[0])} [SEARCH_TERM]...")
        print(f"       {os.path.basename(sys.argv[0])} --download [URL]")
        print(
            f"       {os.path.basename(sys.argv[0])} --checksum [HASH] (Optional with --download)"
        )
        print("Generates EasyEffects presets matching the search terms.")
        print()
        print(f"{YELLOW}Available Presets:{NC}")
        for p in PRESETS:
            print(f"  - {CYAN}{p['name']}{NC}")
        sys.exit(0)

    download_url = None
    checksum = None
    if "--download" in args:
        try:
            idx = args.index("--download")
            download_url = args[idx + 1]
        except IndexError:
            print(f"{RED}Error: Please provide a URL after --download.{NC}")
            sys.exit(1)

    if "--checksum" in args:
        try:
            idx = args.index("--checksum")
            checksum = args[idx + 1]
        except IndexError:
            print(f"{RED}Error: Please provide a hash after --checksum.{NC}")
            sys.exit(1)

    # Checks and Setup
    check_dependencies()
    check_easyeffects()

    if not os.path.exists(TARGET_DIR):
        try:
            os.makedirs(TARGET_DIR)
        except OSError:
            print(
                f"{RED}Error: Cannot create directory {TARGET_DIR}{NC}", file=sys.stderr
            )
            sys.exit(1)

    cleanup_backups()
    generated = []

    if download_url:
        backup_presets()
        generated = download_preset(download_url, checksum)
    else:
        optimize_fedora(args)
        backup_presets()

        print(f"{BLUE}Generating presets in {TARGET_DIR}...{NC}")

        for p in PRESETS:
            # Filter by search terms if provided
            if args:
                match = False
                for term in args:
                    if term.lower() in p["name"].lower():
                        match = True
                        break
                if not match:
                    continue

            sys.stdout.write(f"  Saving: {p['name']} ")
            sys.stdout.flush()

            # Spinner and generation
            stop_spinner = threading.Event()
            t = threading.Thread(target=spinner_task, args=(stop_spinner,), daemon=True)
            t.start()

            try:
                generate_preset_file(p)
                time.sleep(0.2)  # Simulate work/delay so spinner is visible
                stop_spinner.set()
                t.join()
                print(f"{CYAN}-> Done{NC}")
                generated.append(p["name"])
            except Exception as e:
                stop_spinner.set()
                t.join()
                print(f"{RED}-> Failed ({e}){NC}")

    check_active_diff(generated)

    # Check if EasyEffects is running
    try:
        subprocess.run(
            ["pgrep", "-x", "easyeffects"], check=True, stdout=subprocess.DEVNULL
        )
        is_running = True
    except subprocess.CalledProcessError:
        is_running = False

    if is_running:
        print(f"{YELLOW}EasyEffects is running.{NC}")
        if len(generated) == 1:
            choice = (
                input(f"Import (load) '{generated[0]}' now? (y/n) ").strip().lower()
            )
            if choice == "y":
                run_cmd(
                    f'flatpak run com.github.wwmm.easyeffects --load-preset "{generated[0]}"',
                    check=False,
                )
                print(f"{GREEN}Preset loaded.{NC}")
        elif len(generated) > 1:
            print("Select a preset to import (load) now:")
            for i, name in enumerate(generated):
                print(f"  {i + 1}) {name}")
            print(f"  {len(generated) + 1}) Skip")

            try:
                sel = input("#? ")
                idx = int(sel) - 1
                if 0 <= idx < len(generated):
                    name = generated[idx]
                    run_cmd(
                        f'flatpak run com.github.wwmm.easyeffects --load-preset "{name}"',
                        check=False,
                    )
                    print(f"{GREEN}Preset '{name}' loaded.{NC}")
            except ValueError:
                pass
        print(f"{GREEN}Done!{NC}")
    else:
        print(
            f"{GREEN}All presets saved to EasyEffects! Start the app to use them.{NC}"
        )


if __name__ == "__main__":
    main()
