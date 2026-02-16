import os
import sys
import subprocess
import json
import time
import shutil
import threading

# Optional imports for plotting
try:
    import numpy as np
    import matplotlib.pyplot as plt

    MATPLOTLIB_AVAILABLE = True
except ImportError:
    MATPLOTLIB_AVAILABLE = False

# Configuration
HOME = os.path.expanduser("~")
TARGET_DIR = os.path.join(HOME, ".local/share/pipewire-input-presets")
WIREPLUMBER_CONF_DIR = os.path.join(HOME, ".config/wireplumber/wireplumber.conf.d")
LAST_APPLIED_FILE = os.path.join(TARGET_DIR, "last_applied_input.txt")

# Colors
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
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
        "preamp": 2.0,
        "filters": [
            {"type": "bq_highpass", "freq": 250.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_lowpass", "freq": 4000.0, "q": 0.707, "gain": 0.0},
        ],
    },
    {
        "name": "Hum_Remover_50Hz",
        "description": "Removes 50Hz electrical hum (EU/Asia)",
        "preamp": 0.0,
        "filters": [
            {"type": "bq_notch", "freq": 50.0, "q": 10.0, "gain": 0.0},
            {"type": "bq_notch", "freq": 100.0, "q": 10.0, "gain": 0.0},
        ],
    },
    {
        "name": "Hum_Remover_60Hz",
        "description": "Removes 60Hz electrical hum (US/Americas)",
        "preamp": 0.0,
        "filters": [
            {"type": "bq_notch", "freq": 60.0, "q": 10.0, "gain": 0.0},
            {"type": "bq_notch", "freq": 120.0, "q": 10.0, "gain": 0.0},
        ],
    },
    # --- Vocal Enhancements ---
    {
        "name": "Vocal_Clarity_Bright",
        "description": "Boosts treble for clear speech, cuts mud",
        "preamp": 1.0,
        "filters": [
            {"type": "bq_highpass", "freq": 80.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 300.0, "q": 1.0, "gain": -4.0},  # Cut Mud
            {
                "type": "bq_peaking",
                "freq": 4000.0,
                "q": 0.707,
                "gain": 4.0,
            },  # Boost Presence
            {"type": "bq_highshelf", "freq": 8000.0, "q": 0.707, "gain": 2.0},  # Air
        ],
    },
    {
        "name": "Vocal_Warm_Podcast",
        "description": "Radio voice: Warm lows and smooth highs",
        "preamp": 0.0,
        "filters": [
            {"type": "bq_highpass", "freq": 60.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 150.0, "q": 1.0, "gain": 3.0},  # Body
            {
                "type": "bq_peaking",
                "freq": 500.0,
                "q": 1.5,
                "gain": -2.0,
            },  # Boxiness cut
            {"type": "bq_highshelf", "freq": 6000.0, "q": 0.707, "gain": 1.5},
        ],
    },
    {
        "name": "Gaming_Comms_Crisp",
        "description": "Optimized for Discord/TeamSpeak cuts through game audio",
        "preamp": 2.0,
        "filters": [
            {"type": "bq_highpass", "freq": 120.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 2000.0, "q": 1.0, "gain": 3.0},
            {"type": "bq_highshelf", "freq": 5000.0, "q": 0.707, "gain": 4.0},
        ],
    },
    {
        "name": "Broadcast_Compressor",
        "description": "Radio style: Consistent presence and rumble removal",
        "preamp": 3.0,
        "filters": [
            {"type": "bq_highpass", "freq": 80.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 200.0, "q": 1.0, "gain": 2.0},
            {"type": "bq_peaking", "freq": 400.0, "q": 1.0, "gain": -3.0},
            {"type": "bq_peaking", "freq": 2500.0, "q": 1.0, "gain": 4.0},
            {"type": "bq_highshelf", "freq": 10000.0, "q": 0.707, "gain": 2.0},
        ],
    },
    {
        "name": "Studio_Voiceover",
        "description": "Rich, deep voice with air (Proximity effect enhancer)",
        "preamp": 1.5,
        "filters": [
            {"type": "bq_highpass", "freq": 50.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_peaking", "freq": 120.0, "q": 0.8, "gain": 2.5},
            {"type": "bq_peaking", "freq": 600.0, "q": 1.2, "gain": -3.0},
            {"type": "bq_highshelf", "freq": 12000.0, "q": 0.707, "gain": 3.0},
        ],
    },
    {
        "name": "ASMR_High_Sensitivity",
        "description": "Extreme detail, high gain, noise floor cut",
        "preamp": 6.0,
        "filters": [
            {"type": "bq_highpass", "freq": 150.0, "q": 0.707, "gain": 0.0},
            {"type": "bq_highshelf", "freq": 4000.0, "q": 0.5, "gain": 5.0},
        ],
    },
    {
        "name": "Laptop_Mic_Fix",
        "description": "Fixes tinny/hollow laptop microphones",
        "preamp": 4.0,
        "filters": [
            {
                "type": "bq_highpass",
                "freq": 150.0,
                "q": 0.707,
                "gain": 0.0,
            },  # Remove handling noise
            {
                "type": "bq_peaking",
                "freq": 800.0,
                "q": 2.0,
                "gain": -5.0,
            },  # Remove tinny resonance
            {
                "type": "bq_peaking",
                "freq": 2500.0,
                "q": 1.0,
                "gain": 3.0,
            },  # Add intelligibility
        ],
    },
    # --- Utility ---
    {
        "name": "Flat_Response",
        "description": "Passthrough with no coloring",
        "preamp": 0.0,
        "filters": [],
    },
]


def run_cmd(cmd, check=True, capture_output=True):
    """Helper to run shell commands."""
    return subprocess.run(
        cmd, shell=True, check=check, capture_output=capture_output, text=True
    )


def check_dependencies():
    if shutil.which("wireplumber") is None:
        print(
            f"{RED}Error: wireplumber is not installed or not in PATH.{NC}",
            file=sys.stderr,
        )
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
    # Try pactl first (most reliable on standard setups)
    if shutil.which("pactl"):
        res = run_cmd("pactl get-default-source", check=False)
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip()

    # Fallback to pw-dump Metadata
    try:
        res = run_cmd("pw-dump Metadata", check=False)
        if res.stdout:
            data = json.loads(res.stdout)
            for obj in data:
                if obj.get("props", {}).get("metadata.name") == "default":
                    for meta in obj.get("metadata", []):
                        if meta.get("key") == "default.audio.source":
                            val = meta.get("value")
                            # Value might be a JSON object string or raw string
                            try:
                                val_json = json.loads(val)
                                if isinstance(val_json, dict) and "name" in val_json:
                                    return val_json["name"]
                            except (json.JSONDecodeError, TypeError):
                                pass
                            return val
    except Exception:
        pass
    return None


def generate_preset_file(p, target_source=None):
    """Generates the WirePlumber Lua script for Input Processing."""
    nodes_str = ""
    links_str = ""

    preamp_gain = p.get("preamp", 0.0)
    filters = p["filters"]

    # If no filters (Flat), we still create a passthrough node to maintain the virtual device
    if not filters:
        filters = [{"type": "bq_peaking", "freq": 1000.0, "q": 1.0, "gain": 0.0}]

    # Inject Preamp as the first filter if gain is non-zero
    # We use a peaking filter with 0 gain but apply the preamp gain to the node output?
    # Or better, use a biquad with flat response but gain.
    # PipeWire filter-chain doesn't have a simple "gain" node type in builtin,
    # but we can use a bq_peaking with 0 dB gain and apply the preamp elsewhere?
    # Actually, we can just add the preamp gain to the first filter's gain if it's a shelf/peak.
    # But for highpass/notch, gain is ignored.
    # Strategy: Add a dummy peaking filter at 1kHz with the preamp gain if preamp != 0
    # Or just rely on the user to use the volume slider. Let's stick to filters.

    for i, f in enumerate(filters):
        node_name = f"filter_node_{i + 1}"

        # Construct control args based on filter type
        # bq_notch and bq_highpass/lowpass usually don't use Gain, but we include it for consistency if ignored
        control_str = (
            f'["Freq"] = {f["freq"]}, ["Q"] = {f["q"]}, ["Gain"] = {f["gain"]}'
        )

        # Apply preamp to the first node if it's the first one
        # Note: This is a hack. Real preamp should be a separate gain stage.
        # But for this script, we assume the filters do the work.
        # We will ignore preamp in generation for now to keep it clean, or print a note.

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

    # Target specific hardware source if requested
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
    ["audio.channels"] = 1, -- Force Mono for Microphones
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
    filepath = os.path.join(TARGET_DIR, f"{p['name']}.lua")
    with open(filepath, "w") as f:
        f.write(config_content)


def plot_presets(presets_list):
    """Plots the frequency response of input presets."""
    if not MATPLOTLIB_AVAILABLE:
        print(f"{RED}Error: matplotlib and numpy are required for plotting.{NC}")
        return

    plt.figure(figsize=(12, 7))
    fs = 48000
    freqs = np.logspace(np.log10(20), np.log10(20000), 1000)
    w = 2 * np.pi * freqs / fs

    # Pre-calculate z^-1 and z^-2
    z = np.exp(1j * w)
    z_inv = 1 / z
    z_inv_2 = z_inv**2

    print(f"{BLUE}Calculating frequency responses...{NC}")

    for p in presets_list:
        total_response = np.zeros_like(freqs, dtype=complex)
        # Start with unity gain (0dB) or preamp
        preamp_db = p.get("preamp", 0.0)
        current_mag = 10 ** (preamp_db / 20.0)

        # We accumulate magnitude response linearly then convert to dB at the end
        # Actually, cascading filters means multiplying transfer functions H(z)
        H_total = np.ones_like(freqs, dtype=complex) * current_mag

        for f in p["filters"]:
            f0 = f["freq"]
            gain = f["gain"]
            Q = f["q"]
            ftype = f["type"]

            w0 = 2 * np.pi * f0 / fs
            alpha = np.sin(w0) / (2 * Q)
            A = 10 ** (gain / 40)
            cos_w0 = np.cos(w0)

            if ftype == "bq_lowpass":
                b0 = (1 - cos_w0) / 2
                b1 = 1 - cos_w0
                b2 = (1 - cos_w0) / 2
                a0 = 1 + alpha
                a1 = -2 * cos_w0
                a2 = 1 - alpha
            elif ftype == "bq_highpass":
                b0 = (1 + cos_w0) / 2
                b1 = -(1 + cos_w0)
                b2 = (1 + cos_w0) / 2
                a0 = 1 + alpha
                a1 = -2 * cos_w0
                a2 = 1 - alpha
            elif ftype == "bq_peaking":
                b0 = 1 + alpha * A
                b1 = -2 * cos_w0
                b2 = 1 - alpha * A
                a0 = 1 + alpha / A
                a1 = -2 * cos_w0
                a2 = 1 - alpha / A
            elif ftype == "bq_notch":
                b0 = 1
                b1 = -2 * cos_w0
                b2 = 1
                a0 = 1 + alpha
                a1 = -2 * cos_w0
                a2 = 1 - alpha
            elif ftype == "bq_highshelf":
                # RBJ Highshelf
                # A = 10^(gain/40)
                # alpha = sin(w0)/2 * sqrt( (A + 1/A)*(1/Q - 1) + 2 )
                # Simplified alpha for Q param often used:
                b0 = A * ((A + 1) + (A - 1) * cos_w0 + 2 * np.sqrt(A) * alpha)
                b1 = -2 * A * ((A - 1) + (A + 1) * cos_w0)
                b2 = A * ((A + 1) + (A - 1) * cos_w0 - 2 * np.sqrt(A) * alpha)
                a0 = (A + 1) - (A - 1) * cos_w0 + 2 * np.sqrt(A) * alpha
                a1 = 2 * ((A - 1) - (A + 1) * cos_w0)
                a2 = (A + 1) - (A - 1) * cos_w0 - 2 * np.sqrt(A) * alpha
            else:
                continue

            # Normalize
            b = np.array([b0, b1, b2]) / a0
            a = np.array([a0, a1, a2]) / a0

            # Calculate H(z) for this filter
            num = b[0] + b[1] * z_inv + b[2] * z_inv_2
            den = 1 + a[1] * z_inv + a[2] * z_inv_2
            H_total *= num / den

        response_db = 20 * np.log10(np.abs(H_total))
        plt.semilogx(freqs, response_db, label=p["name"])

    plt.title("Input Enhancer Frequency Response")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Gain (dB)")
    plt.grid(True, which="both", ls="-", alpha=0.6)
    plt.axhline(0, color="black", linewidth=0.8)
    plt.legend()
    plt.show()


def reset_enhancer():
    """Disables the enhancer by removing the config and restarting WirePlumber."""
    target_file = os.path.join(WIREPLUMBER_CONF_DIR, "98-input-enhancer.lua")
    if os.path.exists(target_file):
        print(f"{BLUE}Removing input enhancer configuration...{NC}")
        try:
            os.remove(target_file)
            print(f"{BLUE}Restarting WirePlumber...{NC}")
            run_cmd("systemctl --user restart wireplumber", check=False)
            print(f"{GREEN}Input Enhancer disabled.{NC}")
        except OSError as e:
            print(f"{RED}Error removing file: {e}{NC}")
    else:
        print(f"{YELLOW}No active input enhancer found.{NC}")


def install_service():
    """Creates a systemd user service to restore the last preset on boot."""
    service_dir = os.path.join(HOME, ".config/systemd/user")
    os.makedirs(service_dir, exist_ok=True)

    script_path = os.path.abspath(__file__)
    python_path = sys.executable

    service_content = f"""[Unit]
Description=Restore Last Used WirePlumber Input Preset
After=wireplumber.service

[Service]
Type=oneshot
ExecStart={python_path} {script_path} --restore
RemainAfterExit=yes

[Install]
WantedBy=default.target
"""
    service_file = os.path.join(service_dir, "wireplumber-input-loader.service")
    with open(service_file, "w") as f:
        f.write(service_content)

    print(f"{BLUE}Created systemd service at: {service_file}{NC}")
    run_cmd("systemctl --user daemon-reload", check=False)
    run_cmd("systemctl --user enable wireplumber-input-loader.service", check=False)
    print(f"{GREEN}Service enabled. Last used input preset will apply on login.{NC}")


def restore_last_preset():
    """Restores the last applied preset from the tracking file."""
    if not os.path.exists(LAST_APPLIED_FILE):
        print(f"{YELLOW}No last applied input preset found.{NC}")
        return

    try:
        with open(LAST_APPLIED_FILE, "r") as f:
            preset_name = f.read().strip()

        src = os.path.join(TARGET_DIR, f"{preset_name}.lua")
        if os.path.exists(src):
            dest = os.path.join(WIREPLUMBER_CONF_DIR, "98-input-enhancer.lua")
            os.makedirs(WIREPLUMBER_CONF_DIR, exist_ok=True)
            shutil.copy(src, dest)
            run_cmd("systemctl --user restart wireplumber", check=False)
            print(f"{GREEN}Restored last input preset: {preset_name}{NC}")
        else:
            print(f"{RED}Last preset '{preset_name}' not found.{NC}")
    except Exception as e:
        print(f"{RED}Failed to restore preset: {e}{NC}")


def spinner_task(stop_event):
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


def main():
    args = sys.argv[1:]

    if "-h" in args or "--help" in args:
        print(f"{GREEN}Usage:{NC} {os.path.basename(sys.argv[0])}")
        print(f"       {os.path.basename(sys.argv[0])} --reset")
        print(f"       {os.path.basename(sys.argv[0])} --install-service")
        print(f"       {os.path.basename(sys.argv[0])} --restore")
        print(f"       {os.path.basename(sys.argv[0])} --plot [PRESET_NAME]")
        print("\nGenerates Input Enhancer (Mic) presets for WirePlumber.")
        sys.exit(0)

    if "--reset" in args:
        reset_enhancer()
        sys.exit(0)

    if "--install-service" in args:
        install_service()
        sys.exit(0)

    if "--restore" in args:
        restore_last_preset()
        sys.exit(0)

    if "--plot" in args:
        try:
            idx = args.index("--plot")
            search_term = args[idx + 1]
            found = None
            for p in PRESETS:
                if search_term.lower() in p["name"].lower():
                    found = p
                    break
            if found:
                plot_presets([found])
            else:
                print(f"{RED}Error: Preset '{search_term}' not found.{NC}")
        except IndexError:
            print(f"{RED}Error: Please provide a preset name after --plot.{NC}")
        sys.exit(0)

    check_dependencies()

    if not os.path.exists(TARGET_DIR):
        os.makedirs(TARGET_DIR)

    print(f"{BLUE}Generating Input Presets in {TARGET_DIR}...{NC}")

    generated = []
    for p in PRESETS:
        filepath = os.path.join(TARGET_DIR, f"{p['name']}.lua")

        # Optimization: Skip if exists
        if os.path.exists(filepath):
            generated.append(p["name"])
            continue

        sys.stdout.write(f"  Generating: {p['name']} ")
        sys.stdout.flush()

        stop_spinner = threading.Event()
        t = threading.Thread(target=spinner_task, args=(stop_spinner,), daemon=True)
        t.start()

        try:
            generate_preset_file(p)
            time.sleep(0.1)
            stop_spinner.set()
            t.join()
            print(f"{CYAN}-> Done{NC}")
            generated.append(p["name"])
        except Exception as e:
            stop_spinner.set()
            t.join()
            print(f"{RED}-> Failed ({e}){NC}")

    # Selection Menu
    print(f"\n{YELLOW}Available Input Presets:{NC}")
    for i, name in enumerate(generated):
        desc = next((p["description"] for p in PRESETS if p["name"] == name), "")
        print(f"  {i + 1}) {CYAN}{name}{NC} - {desc}")
    print(f"  {len(generated) + 1}) Skip")

    selected_preset = None
    try:
        sel = input("\nSelect preset to apply to Microphone: ")
        idx = int(sel) - 1
        if 0 <= idx < len(generated):
            selected_preset = generated[idx]
        else:
            print("Skipping.")
            sys.exit(0)
    except ValueError:
        sys.exit(0)

    # Device Selection
    sources = get_sources()
    target_source = None

    if sources:
        default_source = get_default_source_name()
        print(f"\n{BLUE}Available Microphones:{NC}")
        for i, (name, desc) in enumerate(sources):
            marker = f" {GREEN}(Default){NC}" if name == default_source else ""
            print(f"  {i + 1}) {desc}{marker}")
        print(f"  a) Auto-Select Default")
        print(f"  n) No Target (Let OS decide)")

        d_choice = input("Bind enhancer to specific mic? (#/a/n) [a]: ").strip().lower()
        if not d_choice:
            d_choice = "a"

        if d_choice == "a":
            if default_source:
                target_source = default_source
                print(f"{YELLOW}Auto-selected: {target_source}{NC}")
            else:
                print(f"{RED}Could not detect default source. Leaving unbound.{NC}")
        elif d_choice == "n":
            print(f"{YELLOW}No target selected. Letting OS decide.{NC}")
        elif d_choice.isdigit():
            idx = int(d_choice) - 1
            if 0 <= idx < len(sources):
                target_source = sources[idx][0]
                print(f"{YELLOW}Targeting: {sources[idx][1]}{NC}")

    # Regenerate selected preset with target if needed
    if target_source:
        for p in PRESETS:
            if p["name"] == selected_preset:
                generate_preset_file(p, target_source=target_source)
                break

    # Apply
    src = os.path.join(TARGET_DIR, f"{selected_preset}.lua")
    dest = os.path.join(WIREPLUMBER_CONF_DIR, "98-input-enhancer.lua")

    os.makedirs(WIREPLUMBER_CONF_DIR, exist_ok=True)
    shutil.copy(src, dest)

    with open(LAST_APPLIED_FILE, "w") as f:
        f.write(selected_preset)

    print(f"{BLUE}Restarting WirePlumber...{NC}")
    run_cmd("systemctl --user restart wireplumber", check=False)

    print(f"\n{GREEN}Success!{NC}")
    print(
        f"A new input device '{CYAN}Input Enhancer: {selected_preset}{NC}' is now available."
    )
    print(
        f"Select this device in your apps (Discord, Zoom, OBS) to use the enhanced audio."
    )


if __name__ == "__main__":
    main()
