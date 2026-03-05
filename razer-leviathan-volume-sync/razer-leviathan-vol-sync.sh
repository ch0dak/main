#!/bin/bash
# Syncs PipeWire/PulseAudio sink volume → Razer Leviathan V2 X hardware master (PCM,1 / numid=4)
# The device ignores per-channel volume (PCM,0 / numid=3) which is what the desktop slider writes to.
# This script bridges the gap by mirroring the slider position to the working master register.

SINK_NAME="alsa_output.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01.analog-stereo"
MAX_HW=151

find_card() {
    grep "Razer Leviathan" /proc/asound/cards 2>/dev/null | grep -o '^ *[0-9]*' | tr -d ' '
}

get_sink_volume_pct() {
    pactl get-sink-volume "$SINK_NAME" 2>/dev/null | head -1 | grep -oP '\d+%' | head -1 | tr -d '%'
}

set_hw_volume() {
    local pct=$1
    local card
    card=$(find_card)
    [ -z "$card" ] && return 1

    local hw_val
    if [ "$pct" -ge 100 ]; then
        hw_val=$MAX_HW
    else
        hw_val=$(( pct * MAX_HW / 100 ))
    fi

    amixer -c "$card" cset numid=4 "$hw_val" >/dev/null 2>&1
}

# Wait for PipeWire
while ! pactl info >/dev/null 2>&1; do
    sleep 1
done

# Wait for the Razer sink to appear
while [ -z "$(get_sink_volume_pct)" ]; do
    sleep 1
done

# Apply current slider position on startup
CURRENT_PCT=$(get_sink_volume_pct)
if [ -n "$CURRENT_PCT" ]; then
    set_hw_volume "$CURRENT_PCT"
fi

# Mirror every subsequent change
pactl subscribe | while read -r line; do
    if [[ "$line" == *"'change' on sink"* ]]; then
        PCT=$(get_sink_volume_pct)
        if [ -n "$PCT" ]; then
            set_hw_volume "$PCT"
        fi
    fi
done
