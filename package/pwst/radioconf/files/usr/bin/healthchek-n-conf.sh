#!/bin/sh

# Log file location
readonly LOGFILE="/var/log/radioconf.log"
readonly MAX_LOG_SIZE=102400  # 100KB in bytes

# Function to log messages
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
    
    # Rotate log if it gets too large
    if [ -f "$LOGFILE" ]; then
        size=$(stat -c%s "$LOGFILE" 2>/dev/null || echo 0)
        if [ "$size" -gt "$MAX_LOG_SIZE" ]; then
            mv "$LOGFILE" "${LOGFILE}.old"
            log_msg "Log rotated (previous log saved as radioconf.log.old)"
        fi
    fi
}

# Maximum attempts (e.g., 60 = 1 minute)
readonly MAX_ATTEMPTS=60
attempt=0

log_msg "Starting Morse health check..."

# Loop until morse_cli health returns 0 or timeout
while [ $attempt -lt $MAX_ATTEMPTS ]; do
    morse_cli health > /dev/null 2>&1
    rc=$?
    
    if [ $rc -eq 0 ]; then
        # Command succeeded, exit loop
        log_msg "Morse health check passed after $attempt attempts"
        break
    else
		log_msg "ERROR: morse_cli health check failed retying in return code $rc"
    fi
    
    # Command failed, increment counter and wait
    attempt=$((attempt + 1))
    sleep 1
done

# Check if we succeeded or timed out
if [ $rc -eq 0 ]; then
    # Health check passed, run duty cycle command
    log_msg "Setting duty cycle spread to 50%"
    morse_cli duty_cycle enable 50 -m 0
    rc=$?
    
    if [ $rc -eq 0 ]; then
        log_msg "Duty cycle configuration completed"
    else
		log_msg "ERROR: morse_cli duty cyle configuration failed in return code $rc"
    fi
else
    log_msg "ERROR: morse_cli health check failed after $MAX_ATTEMPTS attempts"
    exit 1
fi
