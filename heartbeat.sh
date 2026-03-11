#!/bin/bash

AIFREDO_API="${AIFREDO_API:-https://aifredo.chat}"
LICENSE_KEY="${FRED_LICENSE_KEY}"

if [ -z "$LICENSE_KEY" ]; then
  exit 0
fi

# Get uptime in hours
UPTIME_HOURS=$(awk '{print int($1/3600)}' /proc/uptime)

curl -sf -X POST "${AIFREDO_API}/api/sdk/heartbeat" \
  -H "Content-Type: application/json" \
  -d "{\"license_key\":\"${LICENSE_KEY}\",\"version\":\"1.0.0\",\"uptime_hours\":${UPTIME_HOURS}}" \
  > /dev/null 2>&1

echo "💓 Heartbeat sent at $(date)"
