#!/bin/sh
#
# update-meshtastic-port.sh
# Detects the connected Meshtastic USB device and updates the .env conffile
# with its actual serial port. Assumes exactly one Meshtastic device is connected.
#

set -e

ENV_FILE="/usr/share/pwst/gateway/blockchain-lora-wifi-gateway-20260424-124409/docker.env"
KEY="MESHTASTIC_SERIAL_PORT"

# --- Sanity checks -----------------------------------------------------------

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found" >&2
    exit 1
fi

# --- Detect the Meshtastic serial port ---------------------------------------

is_meshtastic_device() {
    case "$1" in
        # Silicon Labs CP210x
        10c4:ea60|10c4:ea70|10c4:ea71|10c4:ea80) return 0 ;;
        # WCH (QinHeng) CH34x / CH91xx
        1a86:7523|1a86:5523|1a86:55d2|1a86:55d3|1a86:55d4|1a86:55d5) return 0 ;;
        # Espressif native USB (ESP32-S2/S3/C3/C6/H2)
        303a:1001|303a:1002|303a:0002) return 0 ;;
        # FTDI (less common but compatible)
        0403:6001|0403:6010|0403:6011|0403:6014|0403:6015) return 0 ;;
        # Prolific (rare but possible)
        067b:2303|067b:2304) return 0 ;;
        # nRF52 / RP2040 / native USB boards (Meshtastic-supported hardware)
        239a:8029|239a:80c6|1915:521f|2e8a:0003|2e8a:000a) return 0 ;;
    esac
    return 1
}

find_ports() {
    for tty in /sys/class/tty/ttyUSB* /sys/class/tty/ttyACM*; do
        [ -e "$tty" ] || continue

        dev_path=$(readlink -f "$tty/device")
        while [ "$dev_path" != "/" ] && [ -n "$dev_path" ]; do
            if [ -f "$dev_path/idVendor" ] && [ -f "$dev_path/idProduct" ]; then
                vid=$(cat "$dev_path/idVendor")
                pid=$(cat "$dev_path/idProduct")
                if is_meshtastic_device "$vid:$pid"; then
                    echo "/dev/${tty##*/}"
                fi
                break
            fi
            dev_path=$(dirname "$dev_path")
        done
    done
}

PORTS=$(find_ports)

if [ -z "$PORTS" ]; then
    echo "Error: no Meshtastic device found on any /dev/ttyUSB* or /dev/ttyACM*" >&2
    exit 2
fi

MATCHES=$(printf '%s\n' "$PORTS" | wc -l)

if [ "$MATCHES" -gt 1 ]; then
    echo "Error: multiple candidate devices found, aborting to avoid ambiguity" >&2
    printf '%s\n' "$PORTS" >&2
    exit 3
fi

PORT="$PORTS"
echo "Detected Meshtastic device at: $PORT"

# --- Update the conffile in place --------------------------------------------

if grep -q "^${KEY}=" "$ENV_FILE"; then
    sed -i "s|^${KEY}=.*|${KEY}=${PORT}|" "$ENV_FILE"
    echo "Updated $KEY in $ENV_FILE"
else
    echo "${KEY}=${PORT}" >> "$ENV_FILE"
    echo "Appended $KEY to $ENV_FILE"
fi

exit 0