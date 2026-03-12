#!/bin/bash
set -u
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

# Target directory for EasyEffects presets (Flatpak path)
TARGET_DIR="$HOME/.var/app/com.github.wwmm.easyeffects/config/easyeffects/output"

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
LATEST_BACKUP_DIR=""

# Check for dependencies
if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}Error: flatpak is not installed or not in PATH.${NC}" >&2
    exit 1
fi

# Check for EasyEffects installation
if ! flatpak info com.github.wwmm.easyeffects &> /dev/null; then
    echo -e "${YELLOW}EasyEffects is not installed.${NC}"
    echo -ne "Install it now via Flatpak? (y/n) "
    read -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        flatpak install -y com.github.wwmm.easyeffects
    else
        echo -e "${RED}EasyEffects is required. Exiting.${NC}" >&2
        exit 1
    fi
fi

# Ensure the directory exists
if ! mkdir -p "$TARGET_DIR"; then
    echo -e "${RED}Error: Cannot create directory $TARGET_DIR${NC}" >&2
    exit 1
fi

# Define presets array: "Filename Loudness LowFreq LowGain MidFreq MidGain HighFreq HighGain"
presets=(
    "Movies_Cinematic -3.0 50.0 6.5 440.0 -8.0 20000.0 4.0"      # Movie Mode (Heavy Bass, Recessed Mids)
    "TV_Clear_Dialogue -1.5 50.0 1.0 440.0 3.5 20000.0 2.0"     # TV/Dialogue Mode (Reduced Bass, Boosted Mids)
    "Music_Bass_Boost -5.0 50.0 7.0 440.0 -1.5 20000.0 2.5"     # Music - Bass Boost (Strong low-end)
    "Music_Bright -6.0 50.0 0.0 440.0 2.0 20000.0 5.5"          # Music - Bright (Treble focus)
    "Gaming_FPS -4.0 50.0 -2.0 440.0 4.5 20000.0 6.0"           # Gaming - FPS (Footsteps focus)
    "Night_Listening -8.0 50.0 -5.0 440.0 0.0 20000.0 -2.0"     # Night Mode (Reduced bass)
    "Music_HipHop_Punchy -4.0 60.0 5.5 440.0 1.0 20000.0 2.0"   # Hip-Hop (Punchy bass at 60Hz)
    "Music_Rock_Metal -3.0 50.0 3.0 440.0 0.0 20000.0 4.5"      # Rock/Metal (Tight bass, crisp highs)
    "Music_Pop_Vocal -3.0 50.0 1.5 440.0 3.0 20000.0 3.0"       # Pop (Balanced with vocal focus)
    "Podcast_Interview -2.0 80.0 -2.0 1000.0 5.0 20000.0 1.0"   # Podcast (Cut rumble <80Hz, Boost speech 1kHz)
    "Music_Electronic -2.0 50.0 6.0 440.0 -1.0 20000.0 4.0"     # Electronic (V-Shape)
    "Music_Acoustic -3.0 50.0 1.0 440.0 4.0 20000.0 2.0"        # Acoustic (Mid-Forward)
    "Vocal_Boost_Call -1.0 100.0 -4.0 1500.0 6.0 20000.0 1.0"   # Calls (Speech Focus at 1.5kHz)
    "Laptop_Speaker_Fix -1.0 50.0 -2.0 440.0 3.0 20000.0 5.0"   # Laptop (Clarity/No Mud)
    "Flat_Response 0.0 50.0 0.0 440.0 0.0 20000.0 0.0"          # Reference (Flat)
    "Movie_Dialogue_Boost -2.0 60.0 -4.0 1200.0 5.0 20000.0 3.0" # Dialogue Focus (Cut rumble, boost speech 1.2kHz)
)

# Check for help flag
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo -e "${GREEN}Usage:${NC} $(basename "$0") [SEARCH_TERM]..."
    echo -e "Generates EasyEffects presets matching the search terms."
    echo
    echo -e "${YELLOW}Available Presets:${NC}"
    for preset in "${presets[@]}"; do
        read -r name _ <<< "$preset"
        echo -e "  - ${CYAN}$name${NC}"
    done
    exit 0
fi

# Function to generate the JSON template
generate_preset() {
    local filename=$1
    local loudness=$2
    local low_freq=$3
    local low_gain=$4
    local mid_freq=$5
    local mid_gain=$6
    local high_freq=$7
    local high_gain=$8

    # Validate inputs are numbers
    if ! [[ $loudness =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || \
       ! [[ $low_freq =~ ^[0-9]+(\.[0-9]+)?$ ]] || \
       ! [[ $low_gain =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || \
       ! [[ $mid_freq =~ ^[0-9]+(\.[0-9]+)?$ ]] || \
       ! [[ $mid_gain =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || \
       ! [[ $high_freq =~ ^[0-9]+(\.[0-9]+)?$ ]] || \
       ! [[ $high_gain =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "${RED}Error: Invalid numeric values for preset '$filename'.${NC}" >&2
        return 1
    fi

    cat <<EOF > "$TARGET_DIR/$filename.json"
{
    "output": {
        "bass_loudness#0": {
            "bypass": false,
            "input-gain": 0.0,
            "link": -9.0,
            "loudness": $loudness,
            "output": -7.0,
            "output-gain": 0.0
        },
        "blocklist": [],
        "equalizer#0": {
            "balance": 0.0,
            "bypass": false,
            "input-gain": 0.0,
            "left": {
                "band0": { "frequency": $low_freq, "gain": $low_gain, "mode": "RLC (BT)", "type": "Bell", "q": 4.36, "width": 4.0 },
                "band5": { "frequency": $mid_freq, "gain": $mid_gain, "mode": "RLC (BT)", "type": "Bell", "q": 4.36, "width": 4.0 },
                "band14": { "frequency": $high_freq, "gain": $high_gain, "mode": "RLC (BT)", "type": "Bell", "q": 4.36, "width": 4.0 }
            },
            "right": {
                "band0": { "frequency": $low_freq, "gain": $low_gain, "mode": "RLC (BT)", "type": "Bell", "q": 4.36, "width": 4.0 },
                "band5": { "frequency": $mid_freq, "gain": $mid_gain, "mode": "RLC (BT)", "type": "Bell", "q": 4.36, "width": 4.0 },
                "band14": { "frequency": $high_freq, "gain": $high_gain, "mode": "RLC (BT)", "type": "Bell", "q": 4.36, "width": 4.0 }
            },
            "mode": "IIR",
            "num-bands": 15,
            "output-gain": 0.0,
            "split-channels": false
        },
        "maximizer#0": {
            "bypass": false,
            "input-gain": 0.0,
            "output-gain": 0.0,
            "release": 25.0,
            "threshold": 0.0
        },
        "plugins_order": [
            "bass_loudness#0",
            "equalizer#0",
            "maximizer#0"
        ]
    }
}
EOF
}

# Function to show a spinner animation
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "[%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
    printf "   \b\b\b"
}

# Function to import (load) a preset into running EasyEffects
import_preset() {
    local preset_name=$1
    flatpak run com.github.wwmm.easyeffects --load-preset "$preset_name" >/dev/null 2>&1
}

# Function to compare the generated preset with the active one (if changed)
check_active_preset_diff() {
    # Try to get the active preset from GSettings
    local active_raw
    active_raw=$(flatpak run --command=gsettings com.github.wwmm.easyeffects get com.github.wwmm.easyeffects last-loaded-preset 2>/dev/null)
    local active_name="${active_raw//\'/}" # Remove quotes

    if [[ -z "$active_name" ]]; then return; fi

    # Check if the active preset was in the list of generated presets
    local was_generated=false
    for gen in "${generated_presets[@]}"; do
        [[ "$gen" == "$active_name" ]] && was_generated=true && break
    done

    if [[ "$was_generated" == "true" && -n "$LATEST_BACKUP_DIR" ]]; then
        local old_file="$LATEST_BACKUP_DIR/$active_name.json"
        local new_file="$TARGET_DIR/$active_name.json"

        if [[ -f "$old_file" && -f "$new_file" ]]; then
            if ! cmp -s "$old_file" "$new_file"; then
                echo
                echo -e "${YELLOW}Changes detected in active preset ('$active_name'):${NC}"
                diff -u "$old_file" "$new_file" --color=always 2>/dev/null || \
                diff -u "$old_file" "$new_file"
            fi
        fi
    fi
}

# Function to optimize PipeWire on Fedora
optimize_fedora_audio() {
    # Only run if no arguments provided (full setup mode)
    if [[ $# -gt 0 ]]; then return; fi

    # Check if running on Fedora to avoid applying Fedora-specific configs elsewhere
    if [ -f /etc/os-release ]; then
        if ! grep -qi "fedora" /etc/os-release; then return; fi
    else
        return
    fi

    echo -e "${BLUE}Checking System Audio (PipeWire) configuration...${NC}"
    local pw_conf_dir="$HOME/.config/pipewire/pipewire.conf.d"
    local pw_conf_file="$pw_conf_dir/99-high-quality.conf"

    if ! pgrep -x "pipewire" > /dev/null; then return; fi

    if [[ ! -f "$pw_conf_file" ]]; then
        echo -e "${YELLOW}Fedora/PipeWire Optimization:${NC}"
        echo "  Enable higher sample rates (48k/96k) and optimized quantum?"
        echo -ne "  Apply? (y/n) "
        read -n 1 -r; echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$pw_conf_dir"
            cat <<EOF > "$pw_conf_file"
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
    default.clock.quantum = 1024
    default.clock.min-quantum = 32
    default.clock.max-quantum = 2048
}
EOF
            echo -e "${GREEN}Config created. Restart PipeWire to apply.${NC}"
        fi
    fi
}

# Function to backup existing presets
backup_presets() {
    shopt -s nullglob
    local files=("$TARGET_DIR"/*.json)
    shopt -u nullglob
    if [ ${#files[@]} -gt 0 ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup_dir="$TARGET_DIR/../presets_backup_$timestamp"
        mkdir -p "$backup_dir"
        LATEST_BACKUP_DIR="$backup_dir"
        cp "${files[@]}" "$backup_dir/"
        echo -e "${GREEN}Backed up existing presets to:${NC} $backup_dir"
    fi
}

# Function to cleanup old backups (older than 7 days)
cleanup_old_backups() {
    local parent_dir="$(dirname "$TARGET_DIR")"
    # Find directories named presets_backup_* older than 7 days and delete them
    find "$parent_dir" -maxdepth 1 -name "presets_backup_*" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null
}

cleanup_old_backups
optimize_fedora_audio "$@"
backup_presets

# Generate Options
echo -e "${BLUE}Generating presets in ${TARGET_DIR}...${NC}"

# Loop through array and generate presets
generated_presets=()
for preset in "${presets[@]}"; do
    read -r name loudness low_f low_g mid_f mid_g high_f high_g <<< "$preset"

    # If command line arguments are provided, check if the preset matches ANY of them
    if [[ $# -gt 0 ]]; then
        match_found=false
        for term in "$@"; do
            if [[ "${name,,}" == *"${term,,}"* ]]; then
                match_found=true
                break
            fi
        done
        [[ "$match_found" == "false" ]] && continue
    fi

    echo -ne "  Saving: $name "
    (generate_preset "$name" "$loudness" "$low_f" "$low_g" "$mid_f" "$mid_g" "$high_f" "$high_g" && sleep 0.2) &
    pid=$!
    show_spinner $pid
    wait $pid
    if [ $? -eq 0 ]; then
        echo -e "${CYAN}-> Done${NC}"
        generated_presets+=("$name")
    else
        echo -e "${RED}-> Failed${NC}"
    fi
done

check_active_preset_diff

# Check if EasyEffects is running and prompt to restart
if pgrep -x "easyeffects" > /dev/null; then
    echo -e "${YELLOW}EasyEffects is running.${NC}"
    
    if [ ${#generated_presets[@]} -eq 1 ]; then
        echo -ne "Import (load) '${generated_presets[0]}' now? (y/n) "
        read -n 1 -r; echo
        [[ $REPLY =~ ^[Yy]$ ]] && import_preset "${generated_presets[0]}" && echo -e "${GREEN}Preset loaded.${NC}"
    elif [ ${#generated_presets[@]} -gt 1 ]; then
        echo "Select a preset to import (load) now:"
        select p in "${generated_presets[@]}" "Skip"; do
            if [[ "$p" == "Skip" ]]; then break; fi
            if [[ -n "$p" ]]; then
                import_preset "$p"
                echo -e "${GREEN}Preset '$p' loaded.${NC}"
                break
            fi
        done
    fi
    echo -e "${GREEN}Done!${NC}"
else
    echo -e "${GREEN}All presets saved to EasyEffects! Start the app to use them.${NC}"
fi
