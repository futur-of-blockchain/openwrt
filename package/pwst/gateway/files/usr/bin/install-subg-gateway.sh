#!/bin/sh
################################################################################
# Log file location
readonly LOGFILE="/var/log/subghzgateway.log"
readonly MAX_LOG_SIZE=102400  # 100KB in bytes
readonly GATEWAY_PACKAGED_CODE="blockchain-lora-wifi-gateway-20260112-094902"
readonly GATEWAY_PACKAGED_CODE_TAR="${GATEWAY_PACKAGED_CODE}.tar.gz"
readonly PACKAGE_DIR="/usr/share/pwst/gateway/"
readonly TARGET_DIR="${PACKAGE_DIR}${GATEWAY_PACKAGED_CODE}"
readonly TARBALL="${PACKAGE_DIR}${GATEWAY_PACKAGED_CODE_TAR}"
################################################################################
# Rotate log if it's grown too large. Called before writing, not after.
rotate_log_if_needed() {
    [ -f "$LOGFILE" ] || return 0
    size=$(stat -c%s "$LOGFILE" 2>/dev/null || echo 0)
    if [ "$size" -gt "$MAX_LOG_SIZE" ]; then
        mv "$LOGFILE" "${LOGFILE}.old"
    fi
}

# Log a message with timestamp
log_msg() {
    rotate_log_if_needed
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}
################################################################################
# Extract code
log_msg "Starting unzipping the gateway package"

if [ ! -f "$TARBALL" ]; then
    log_msg "ERROR: tarball not found at $TARBALL"
    exit 1
fi

mkdir -p "$TARGET_DIR"

if tar -xzf "$TARBALL" -C "$TARGET_DIR"; then
    log_msg "Gateway package unzipped successfully"
else
    log_msg "ERROR: Failed to untargzip the gateway package"
    exit 1
fi
################################################################################
# Docker build
log_msg "Build docker image and docker compose"

if ! cd "$TARGET_DIR"; then
    log_msg "ERROR: cannot cd into $TARGET_DIR"
    exit 1
fi

if make build; then
    log_msg "Docker image built successfully"
else
    log_msg "ERROR: Failed to build the docker image"
    exit 1
fi