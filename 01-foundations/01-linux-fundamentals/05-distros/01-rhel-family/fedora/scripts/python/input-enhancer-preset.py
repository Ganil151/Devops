import os
import sys
import subprocess
import json
import time
import shutil
import threading
import argparse
from pathlib import Path

# Optional imports for plotting
try:
    import numpy as np
    import matplotlib.pyplot as plt

    MATPLOTLIB_AVAILABLE = True
except ImportError:
    MATPLOTLIB_AVAILABLE = False

# Configuration
HOME = Path.home()
TARGET_DIR = HOME / ".local/share/pipewire-input-presets"
WIREPLUMBER_CONF_DIR = HOME / ".config/wireplumber/wireplumber.conf.d"
LAST_APPLIED_FILE = TARGET_DIR / "last_applied_input.txt"
MAIN_CONF_FILE = WIREPLUMBER_CONF_DIR / "98-input-enhancer.lua"

# Colors
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
MAGENTA = "\033[0;35m"
NC = "\033[0m"

# Presets Data (Input Focused)
PRESETS = [
    # --- Noise Reduction (Filtering) ---
    {
        "name": "Noise_Reducer_Rumble",
        "description": "Removes low-end desk rumble and AC noise (<100Hz)",
        "preamp": 0.0,
        "filters": [
            {"type": "bq_highpass", "freq": 100.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_lowpass", "freq": 12000.0, "q": 0.707, "gain": 0.0},
        ],
    },
    {
        "name": "Noise_Reducer_Aggressive",
        "description": "Tight bandpass for noisy environments (Walkie-Talkie style)",
        "preamp": 3.0,
        "filters": [
            {"type": "bq_highpass", "freq": 250.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_lowpass", "freq": 3500.0, "q": 0.707, "gain": 0.0},
        ],
    },
    {
        "name": "Hum_Remover_50Hz",
        "description": "Removes 50Hz electrical hum (EU/Asia)",
        "preamp": 0.0,
        "filters": [
            {"type": "bq_notch", "freq": 50.0, "q": 10.0, "gain": 0.0},
            {"type": "bq_notch", "freq": 100.0, "q": 10.0, "gain": 0.0},
            {"type": "bq_notch", "freq": 150.0, "q": 10.0, "gain": 0.0},
        ],
    },
    {
        "name": "Hum_Remover_60Hz",
        "description": "Removes 60Hz electrical hum (US/Americas)",
        "preamp": 0.0,
        "filters": [
            {"type": "bq_notch", "freq": 60.0, "q": 10.0, "gain": 0.0},
            {"type": "bq_notch", "freq": 120.0, "q": 10.0, "gain": 0.0},
            {"type": "bq_notch", "freq": 180.0, "q": 10.0, "gain": 0.0},
        ],
    },
    # --- Vocal Enhancements ---
    {
        "name": "Vocal_Clarity_Bright",
        "description": "Boosts treble for clear speech, cuts mid-range mud",
        "preamp": 1.5,
        "filters": [
            {"type": "bq_highpass", "freq": 85.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 300.0, "q": 1.2, "gain": -4.5},
            {"type": "bq_peaking", "freq": 3500.0, "q": 0.8, "gain": 4.0},
            {"type": "bq_highshelf", "freq": 8000.0, "q": 0.707, "gain": 2.5},
        ],
    },
    {
        "name": "Vocal_Warm_Podcast",
        "description": "Rich bottom end with smooth, airy highs",
        "preamp": 0.5,
        "filters": [
            {"type": "bq_highpass", "freq": 65.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 160.0, "q": 1.0, "gain": 3.5},
            {"type": "bq_peaking", "freq": 550.0, "q": 1.8, "gain": -2.5},
            {"type": "bq_peaking", "freq": 4500.0, "q": 0.9, "gain": 1.5},
            {"type": "bq_highshelf", "freq": 10000.0, "q": 0.707, "gain": 2.0},
        ],
    },
    {
        "name": "Gaming_Comms_Crisp",
        "description": "Discord optimized: Cuts through explosions and music",
        "preamp": 2.5,
        "filters": [
            {"type": "bq_highpass", "freq": 125.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 1000.0, "q": 0.7, "gain": -2.0},
            {"type": "bq_peaking", "freq": 2800.0, "q": 1.2, "gain": 5.0},
            {"type": "bq_highshelf", "freq": 6000.0, "q": 0.707, "gain": 4.5},
        ],
    },
    {
        "name": "Broadcast_Pro",
        "description": "Studio quality: Compressed feel with high intelligibility",
        "preamp": 4.0,
        "filters": [
            {"type": "bq_highpass", "freq": 75.0, "q": 0.8, "gain": 0.0},
            {"type": "bq_peaking", "freq": 220.0, "q": 1.1, "gain": 2.5},
            {"type": "bq_peaking", "freq": 450.0, "q": 1.4, "gain": -3.5},
            {"type": "bq_peaking", "freq": 3200.0, "q": 1.0, "gain": 4.5},
            {"type": "bq_peaking", "freq": 7000.0, "q": 1.2, "gain": 2.0},
            {"type": "bq_highshelf", "freq": 12000.0, "q": 0.707, "gain": 3.0},
        ],
    },
    {
        "name": "Deep_Voice_Enhancer",
        "description": "Enhances sub-harmonics for a 'Voice of God' effect",
        "preamp": 1.0,
        "filters": [
            {"type": "bq_highpass", "freq": 45.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 100.0, "q": 0.8, "gain": 5.0},
            {"type": "bq_peaking", "freq": 400.0, "q": 1.5, "gain": -4.0},
            {"type": "bq_highshelf", "freq": 10000.0, "q": 0.707, "gain": -2.0},
        ],
    },
    {
        "name": "Meeting_Focus",
        "description": "Optimized for intelligibility in video calls",
        "preamp": 2.0,
        "filters": [
            {"type": "bq_highpass", "freq": 150.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 3000.0, "q": 1.0, "gain": 3.5},
            {"type": "bq_lowpass", "freq": 7000.0, "q": 0.707, "gain": 0.0},
        ],
    },
    {
        "name": "Laptop_Mic_Fix_V2",
        "description": "Revives thin, metallic laptop microphones",
        "preamp": 5.0,
        "filters": [
            {"type": "bq_highpass", "freq": 180.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 900.0, "q": 2.5, "gain": -6.0},
            {"type": "bq_peaking", "freq": 2500.0, "q": 1.2, "gain": 4.5},
            {"type": "bq_peaking", "freq": 5000.0, "q": 0.8, "gain": 3.0},
        ],
    },
    {
        "name": "Flat_Response",
        "description": "Neutral passthrough for comparison",
        "preamp": 0.0,
        "filters": [],
    },
]


def run_cmd(cmd, check=True, capture_output=True):
    """Helper to run shell commands."""
    try:
        return subprocess.run(
            cmd, shell=True, check=check, capture_output=capture_output, text=True
        )
    except subprocess.CalledProcessError as e:
        if check:
            raise e
        return e


def cleanup_orphans():
    """Removes Lua files in TARGET_DIR that don't match any current PRESET names."""
    if not TARGET_DIR.exists():
        return
    
    current_names = {p["name"] for p in PRESETS}
    deleted = 0
    for f in TARGET_DIR.glob("*.lua"):
        if f.stem not in current_names:
            f.unlink()
            deleted += 1
    if deleted:
        print(f"{BLUE}Cleaned up {deleted} orphaned preset files.{NC}")


def optimize_fedora():
    """Checks for Fedora and offers PipeWire optimization."""
    os_release = Path("/etc/os-release")
    if not os_release.exists():
        return
    
    if "fedora" not in os_release.read_text().lower():
        return

    pw_conf_dir = HOME / ".config/pipewire/pipewire.conf.d"
    pw_conf_file = pw_conf_dir / "99-high-quality.conf"

    if not pw_conf_file.exists():
        print(f"\n{YELLOW}Fedora/PipeWire Optimization detected:{NC}")
        print("Set system-wide 48kHz/96kHz sample rates and optimized buffer sizes?")
        choice = input("Apply high-quality config? (y/n) [n]: ").strip().lower()
        if choice == "y":
            pw_conf_dir.mkdir(parents=True, exist_ok=True)
            config_content = """context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
    default.clock.quantum = 1024
    default.clock.min-quantum = 32
    default.clock.max-quantum = 2048
}
"""
            pw_conf_file.write_text(config_content)
            print(f"{GREEN}Created {pw_conf_file}. Restart PipeWire/Session to apply.{NC}")


def check_dependencies():
    """Verify required system tools are available."""
    missing = []
    for tool in ["wireplumber", "pw-dump"]:
        if shutil.which(tool) is None:
            missing.append(tool)
    
    if missing:
        print(f"{RED}Error: Missing dependencies: {', '.join(missing)}{NC}", file=sys.stderr)
        sys.exit(1)


def get_sources():
    """Retrieves available audio sources (microphones) using pw-dump."""
    try:
        res = run_cmd("pw-dump", check=False)
        if not res.stdout:
            return []
        data = json.loads(res.stdout)
        sources = []
        for obj in data:
            props = obj.get("info", {}).get("props", {})
            if props.get("media.class") == "Audio/Source":
                # Exclude our own virtual sources
                if "Input Enhancer" in props.get("node.description", ""):
                    continue
                name = props.get("node.name")
                desc = props.get("node.description", name)
                sources.append((name, desc))
        return sources
    except Exception:
        return []


def get_default_source_name():
    """Attempts to find the system default audio source."""
    # Try pactl first (standard on many distros)
    if shutil.which("pactl"):
        res = run_cmd("pactl get-default-source", check=False)
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip()

    # Fallback to pw-metadata
    if shutil.which("pw-metadata"):
        res = run_cmd("pw-metadata -n settings 0 default.audio.source", check=False)
        if res.returncode == 0 and res.stdout.strip():
             # Parsing pw-metadata output can be tricky, it usually contains more than just the name
             # But often it's the last word or in quotes
             for line in res.stdout.splitlines():
                 if "value:" in line:
                     val = line.split("value:")[-1].strip().strip("'\"")
                     try:
                         val_json = json.loads(val)
                         if isinstance(val_json, dict) and "name" in val_json:
                             return val_json["name"]
                     except:
                         return val
    
    return None


def generate_preset_file(p, target_source=None):
    """Generates the WirePlumber Lua script for Input Processing."""
    nodes_str = ""
    links_str = ""

    preamp_gain = p.get("preamp", 0.0)
    filters = list(p["filters"])

    # Handle Preamp: PipeWire doesn't have a direct 'gain' filter in filter-chain easily,
    # but we can hack it by using a peaking filter with 0 gain and setting 'node.volume' or similar.
    # Alternatively, we just add the preamp gain to ALL filters that support it, or the first one.
    # BEST APPROACH: Use a peaking filter at 1000Hz, Q=0.1 (very wide) and apply preamp gain there.
    if preamp_gain != 0:
        filters.insert(0, {"type": "bq_peaking", "freq": 1000.0, "q": 0.01, "gain": preamp_gain})

    # If no filters (Flat), we still create a passthrough node
    if not filters:
        filters = [{"type": "bq_peaking", "freq": 1000.0, "q": 1.0, "gain": 0.0}]

    for i, f in enumerate(filters):
        node_name = f"filter_node_{i + 1}"
        control_str = f'["Freq"] = {f["freq"]}, ["Q"] = {f["q"]}, ["Gain"] = {f["gain"]}'

        nodes_str += f"""            {{
                type  = "builtin",
                name  = "{node_name}",
                label = "{f["type"]}",
                control = {{ {control_str} }}
            }},
"""
        # Link logic
        if i < len(filters) - 1:
            next_node = f"filter_node_{i + 2}"
            links_str += f'            {{ output = "{node_name}:Out", input = "{next_node}:In" }},\n'

    nodes_str = nodes_str.rstrip(",\n")
    links_str = links_str.rstrip(",\n")

    # Target specific hardware source
    target_str = ""
    if target_source:
        target_str = f', ["node.target"] = "{target_source}"'

    config_content = f"""-- Generated by InputEnhancerGenerator for {p["name"]}
local filter_args = {{
    ["node.description"] = "Input Enhancer: {p["name"]}",
    ["media.name"]       = "Input Enhancer: {p["name"]}",
    ["filter.graph"] = {{
        ["nodes"] = {{
{nodes_str}
        }},
        ["links"] = {{
{links_str}
        }}
    }},
    ["audio.channels"] = 1,
    ["audio.position"] = {{ "MONO" }},
    ["capture.props"] = {{
        ["node.name"]   = "effect_input.mic",
        ["node.passive"] = true{target_str}
    }},
    ["playback.props"] = {{
        ["node.name"]   = "effect_output.mic",
        ["media.class"] = "Audio/Source"
    }}
}}

LocalModule("libpipewire-module-filter-chain", filter_args)
"""
    TARGET_DIR.mkdir(parents=True, exist_ok=True)
    filepath = TARGET_DIR / f"{p['name']}.lua"
    with open(filepath, "w") as f:
        f.write(config_content)
    return filepath


def plot_presets(presets_list):
    """Plots the frequency response of input presets."""
    if not MATPLOTLIB_AVAILABLE:
        print(f"{RED}Error: matplotlib and numpy are required for plotting.{NC}")
        return

    plt.figure(figsize=(12, 7))
    fs = 48000
    freqs = np.logspace(np.log10(20), np.log10(20000), 1000)
    w = 2 * np.pi * freqs / fs
    z = np.exp(1j * w)
    z_inv = 1 / z
    z_inv_2 = z_inv**2

    print(f"{BLUE}Calculating frequency responses...{NC}")

    for p in presets_list:
        preamp_db = p.get("preamp", 0.0)
        H_total = np.ones_like(freqs, dtype=complex) * (10 ** (preamp_db / 20.0))

        for f in p["filters"]:
            f0, gain, Q, ftype = f["freq"], f["gain"], f["q"], f["type"]
            w0 = 2 * np.pi * f0 / fs
            alpha = np.sin(w0) / (2 * Q)
            A = 10 ** (gain / 40)
            cos_w0 = np.cos(w0)

            if ftype == "bq_lowpass":
                b = [(1-cos_w0)/2, 1-cos_w0, (1-cos_w0)/2]
                a = [1+alpha, -2*cos_w0, 1-alpha]
            elif ftype == "bq_highpass":
                b = [(1+cos_w0)/2, -(1+cos_w0), (1+cos_w0)/2]
                a = [1+alpha, -2*cos_w0, 1-alpha]
            elif ftype == "bq_peaking":
                b = [1+alpha*A, -2*cos_w0, 1-alpha*A]
                a = [1+alpha/A, -2*cos_w0, 1-alpha/A]
            elif ftype == "bq_notch":
                b = [1, -2*cos_w0, 1]
                a = [1+alpha, -2*cos_w0, 1-alpha]
            elif ftype == "bq_highshelf":
                sqrtA2alpha = 2 * np.sqrt(A) * alpha
                b = [A*((A+1)+(A-1)*cos_w0+sqrtA2alpha), -2*A*((A-1)+(A+1)*cos_w0), A*((A+1)+(A-1)*cos_w0-sqrtA2alpha)]
                a = [(A+1)-(A-1)*cos_w0+sqrtA2alpha, 2*((A-1)-(A+1)*cos_w0), (A+1)-(A-1)*cos_w0-sqrtA2alpha]
            else: continue

            # Normalize and calc
            b, a = np.array(b)/a[0], np.array(a)/a[0]
            num = b[0] + b[1]*z_inv + b[2]*z_inv_2
            den = 1 + a[1]*z_inv + a[2]*z_inv_2
            H_total *= num / den

        response_db = 20 * np.log10(np.maximum(np.abs(H_total), 1e-10))
        plt.semilogx(freqs, response_db, label=p["name"])

    plt.title("Input Enhancer Frequency Response Curves")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Gain (dB)")
    plt.ylim(-20, 25)
    plt.grid(True, which="both", ls="-", alpha=0.4)
    plt.axhline(0, color="black", linewidth=1)
    plt.legend()
    plt.show()


def reset_enhancer():
    """Disables the enhancer by removing the config and restarting WirePlumber."""
    if MAIN_CONF_FILE.exists():
        print(f"{BLUE}Removing input enhancer configuration...{NC}")
        try:
            MAIN_CONF_FILE.unlink()
            print(f"{BLUE}Restarting WirePlumber...{NC}")
            run_cmd("systemctl --user restart wireplumber", check=False)
            if LAST_APPLIED_FILE.exists():
                LAST_APPLIED_FILE.unlink()
            print(f"{GREEN}Input Enhancer disabled.{NC}")
        except Exception as e:
            print(f"{RED}Error: {e}{NC}")
    else:
        print(f"{YELLOW}No active input enhancer found.{NC}")


def install_service():
    """Creates a systemd user service to restore the last preset on boot."""
    service_dir = HOME / ".config/systemd/user"
    service_dir.mkdir(parents=True, exist_ok=True)

    script_path = Path(__file__).absolute()
    service_content = f"""[Unit]
Description=Restore WirePlumber Input Preset
After=wireplumber.service

[Service]
Type=oneshot
ExecStart={sys.executable} {script_path} --restore
RemainAfterExit=yes

[Install]
WantedBy=default.target
"""
    service_file = service_dir / "wireplumber-input-loader.service"
    with open(service_file, "w") as f:
        f.write(service_content)

    run_cmd("systemctl --user daemon-reload", check=False)
    run_cmd("systemctl --user enable wireplumber-input-loader.service", check=False)
    print(f"{GREEN}Auto-restore service enabled.{NC}")


def restore_last_preset():
    """Restores the last applied preset."""
    if not LAST_APPLIED_FILE.exists():
        return

    preset_name = LAST_APPLIED_FILE.read_text().strip()
    src = TARGET_DIR / f"{preset_name}.lua"
    
    if src.exists():
        WIREPLUMBER_CONF_DIR.mkdir(parents=True, exist_ok=True)
        shutil.copy(src, MAIN_CONF_FILE)
        run_cmd("systemctl --user restart wireplumber", check=False)
        print(f"{GREEN}Restored preset: {preset_name}{NC}")
    else:
        print(f"{RED}Preset '{preset_name}' not found for restoration.{NC}")


def get_status():
    """Shows the currently active preset."""
    if not MAIN_CONF_FILE.exists():
        print(f"{YELLOW}Status: Disabled{NC}")
        return

    if LAST_APPLIED_FILE.exists():
        preset_name = LAST_APPLIED_FILE.read_text().strip()
        print(f"{GREEN}Status: Active ({preset_name}){NC}")
    else:
        print(f"{CYAN}Status: Active (Manual/External config){NC}")


def spinner_task(stop_event):
    spinstr = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    while not stop_event.is_set():
        for char in spinstr:
            if stop_event.is_set(): break
            sys.stdout.write(f"\r{CYAN}[{char}]{NC} Working...")
            sys.stdout.flush()
            time.sleep(0.08)
    sys.stdout.write("\r             \r")


def interactive_menu():
    """Standard interactive flow."""
    check_dependencies()
    optimize_fedora()
    cleanup_orphans()
    
    # 1. Generate all presets
    print(f"{BLUE}Refreshing preset files in {TARGET_DIR}...{NC}")
    stop_spinner = threading.Event()
    t = threading.Thread(target=spinner_task, args=(stop_spinner,), daemon=True)
    t.start()
    
    for p in PRESETS:
        generate_preset_file(p)
    
    stop_spinner.set()
    t.join()
    print(f"{GREEN}Presets refreshed.{NC}")

    # 2. Selection
    print(f"\n{YELLOW}--- Available Input Presets ---{NC}")
    for i, p in enumerate(PRESETS):
        print(f"  {i + 1:2d}) {CYAN}{p['name']:<25}{NC} - {p['description']}")
    print(f"   0) {RED}Disable Enhancer{NC}")
    print(f"   s) Skip / Exit")

    choice = input(f"\nSelect a preset (1-{len(PRESETS)}): ").strip().lower()
    
    if choice == '0':
        reset_enhancer()
        return
    if choice == 's' or not choice:
        return

    try:
        idx = int(choice) - 1
        selected_p = PRESETS[idx]
    except (ValueError, IndexError):
        print(f"{RED}Invalid selection.{NC}")
        return

    # 3. Device selection
    sources = get_sources()
    target_source = None
    if sources:
        default_source = get_default_source_name()
        print(f"\n{BLUE}--- Available Microphones ---{NC}")
        for i, (name, desc) in enumerate(sources):
            marker = f" {GREEN}[Default]{NC}" if name == default_source else ""
            print(f"  {i + 1}) {desc}{marker}")
        print(f"  a) Auto-Select Default")
        print(f"  n) Generic (No binding)")

        mic_choice = input("\nBind to which mic? (1/a/n) [a]: ").strip().lower() or 'a'
        
        if mic_choice == 'a':
            target_source = default_source
        elif mic_choice.isdigit():
            s_idx = int(mic_choice) - 1
            if 0 <= s_idx < len(sources):
                target_source = sources[s_idx][0]
        
    # 4. Apply
    print(f"\n{BLUE}Applying {selected_p['name']}...{NC}")
    final_file = generate_preset_file(selected_p, target_source)
    shutil.copy(final_file, MAIN_CONF_FILE)
    LAST_APPLIED_FILE.write_text(selected_p['name'])
    
    run_cmd("systemctl --user restart wireplumber", check=False)
    
    print(f"\n{GREEN}Success!{NC}")
    print(f"Active Virtual Device: {CYAN}Input Enhancer: {selected_p['name']}{NC}")
    print(f"Bound to Hardware: {YELLOW}{target_source or 'None (System Default)'}{NC}")


def main():
    parser = argparse.ArgumentParser(description="PipeWire Input Enhancer Utility")
    parser.add_argument("--list", action="store_true", help="List available presets")
    parser.add_argument("--status", action="store_true", help="Show current status")
    parser.add_argument("--reset", action="store_true", help="Disable the enhancer")
    parser.add_argument("--restore", action="store_true", help="Restore last preset")
    parser.add_argument("--install-service", action="store_true", help="Install auto-restore service")
    parser.add_argument("--plot", nargs="?", const="all", help="Plot frequency response (provide name or 'all')")
    parser.add_argument("--apply", metavar="PRESET", help="Apply a specific preset by name")

    args = parser.parse_args()

    if args.list:
        print(f"{YELLOW}Available Presets:{NC}")
        for p in PRESETS:
            print(f"  - {CYAN}{p['name']:<25}{NC} {p['description']}")
        return

    if args.status:
        get_status()
        return

    if args.reset:
        reset_enhancer()
        return

    if args.restore:
        restore_last_preset()
        return

    if args.install_service:
        install_service()
        return

    if args.plot:
        if args.plot == "all":
            plot_presets(PRESETS)
        else:
            matches = [p for p in PRESETS if args.plot.lower() in p["name"].lower()]
            if matches:
                plot_presets(matches)
            else:
                print(f"{RED}No preset matching '{args.plot}' found.{NC}")
        return

    if args.apply:
        matches = [p for p in PRESETS if args.apply.lower() == p["name"].lower()]
        if matches:
            selected_p = matches[0]
            final_file = generate_preset_file(selected_p)
            shutil.copy(final_file, MAIN_CONF_FILE)
            LAST_APPLIED_FILE.write_text(selected_p['name'])
            run_cmd("systemctl --user restart wireplumber", check=False)
            print(f"{GREEN}Applied {selected_p['name']}{NC}")
        else:
            print(f"{RED}Preset '{args.apply}' not found.{NC}")
        return

    # Default to interactive menu
    interactive_menu()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nAborted.")
        sys.exit(0)