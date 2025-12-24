#!/bin/sh

# SETTINGS
BASEDIR="/mnt/us/extensions/timelit"
STOP_FILE="/mnt/us/STOP"

# 1. THE FAILSAFE (Always check this first!)
if [ -f "$STOP_FILE" ]; then
    rm -f "$BASEDIR/clockisticking"
    rm -f "$STOP_FILE"

    # Restore default power and UI behavior
    lipc-set-prop com.lab126.powerd -i res_on_time 1
    lipc-set-prop com.lab126.powerd deferSuspend 0
    lipc-set-prop com.lab126.powerd preventScreenSaver 0

    # Restart the UI services
    start lab126_gui
    start framework
    initctl start webreader >/dev/null 2>&1

    eips -c
    eips 0 0 "UI Restored. Please wait for Home to load..."
    exit 0
fi

# 2. APP STATE CHECK
# If the trigger file doesn't exist, we don't run the clock logic.
test -f "$BASEDIR/clockisticking" || exit

# 3. UI SUPPRESSION (Re-assertion)
# We run these every minute. If they are already off, this is harmless.
stop framework >/dev/null 2>&1
stop lab126_gui >/dev/null 2>&1
initctl stop webreader >/dev/null 2>&1

# 4. POWER MANAGEMENT (Crucial Heartbeat)
lipc-set-prop com.lab126.powerd preventScreenSaver 1
lipc-set-prop com.lab126.powerd status active
lipc-set-prop com.lab126.powerd deferSuspend 1
lipc-set-prop com.lab126.powerd -i res_on_time 0
echo 1 > /sys/devices/platform/mxc_epdc.0/wake_up 2>/dev/null

# 5. DRAWING LOGIC
MinuteOTheDay=$(date +"%H%M")
ThisMinuteImage=$(find "$BASEDIR/images/quote_$MinuteOTheDay"* 2>/dev/null | shuf -n 1)

if [ -z "$ThisMinuteImage" ]; then
    # Optional: Draw a 'Missing Quote' image or just exit
    exit
fi

# Full refresh every 20 mins to prevent ghosting
clearFlag=""
if echo "$MinuteOTheDay" | grep -q '..[024]0$'; then
    clearFlag="-f"
fi

# Display the quote
eips $clearFlag -g "$ThisMinuteImage"