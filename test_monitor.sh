#!/bin/bash

PROCESS_NAME="test"
LOG_FILE="/var/log/monitoring.log"
API_URL="https://test.com/monitoring/test/api"
STATE_FILE="/var/run/test_monitor_state"

# Сheck process presence
PID=$(pgrep -x "$PROCESS_NAME")
if [[ -z "$PID" ]]; then
    exit 0
fi

# PID change check
if [[ -f "$STATE_FILE" ]]; then
    LAST_PID=$(cat "$STATE_FILE")
    if [[ "$LAST_PID" != "$PID" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Process $PROCESS_NAME restarted: Old PID=$LAST_PID, New PID=$PID" >> "$LOG_FILE"
    fi
fi

echo "$PID" > "$STATE_FILE"

# Attempt to connect to server
curl -s --connect-timeout 5 --max-time 10 "$API_URL" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Monitoring server not reachable at $API_URL" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') Successfully pinged $API_URL" >> "$LOG_FILE"
fi
