#!/bin/bash
set -e

AIFREDO_API="${AIFREDO_API:-https://aifredo.chat}"
LICENSE_KEY="${FRED_LICENSE_KEY}"
SOUL_PATH="/app/backend/.deer-flow/agents/fred/SOUL.md"

echo "🤖 Fred SDK booting..."

if [ -z "$LICENSE_KEY" ]; then
  echo "⚠️  No FRED_LICENSE_KEY set — starting in demo mode"
  exec "$@"
fi

echo "📡 Fetching config from control plane..."
RESPONSE=$(curl -sf "${AIFREDO_API}/api/sdk/config/${LICENSE_KEY}" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
  echo "⚠️  Could not reach AiFredo control plane — using cached config"
  exec "$@"
fi

VALID=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('valid','false'))")

if [ "$VALID" != "True" ] && [ "$VALID" != "true" ]; then
  echo "❌ Invalid license — starting in demo mode"
  exec "$@"
fi

AGENT_NAME=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['fred']['agent_name'])")
BUSINESS_NAME=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['fred']['business_name'])")
BUSINESS_DESC=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['fred']['business_description'])")
TARGET_MARKET=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['fred']['target_market'])")
TONE=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['fred']['tone'])")

echo "✅ License valid — configuring Fred for: $BUSINESS_NAME"

mkdir -p "$(dirname $SOUL_PATH)"

python3 - << PYEOF
import os
soul = f"""# {os.environ.get('AGENT_NAME', 'Fred')} — AI Business Development Agent

## Identity
You are {os.environ.get('AGENT_NAME', 'Fred')}, the dedicated AI business development agent for {os.environ.get('BUSINESS_NAME', '')}.

## About the Business
{os.environ.get('BUSINESS_DESC', '')}

## Target Market
{os.environ.get('TARGET_MARKET', '')}

## Tone
{os.environ.get('TONE', 'professional')}

## Your Role
- Find and research prospects matching the target market
- Write personalised outreach emails
- Follow up on leads
- Book meetings via Google Calendar
- Manage the prospect pipeline

## Rules
- Always represent {os.environ.get('BUSINESS_NAME', '')} professionally
- Never make up information about the business
- Keep outreach concise and value-focused
"""
open('{SOUL_PATH}', 'w').write(soul)
print('📝 SOUL.md written')
PYEOF

export AGENT_NAME="$AGENT_NAME"
export BUSINESS_NAME="$BUSINESS_NAME"
export BUSINESS_DESC="$BUSINESS_DESC"
export TARGET_MARKET="$TARGET_MARKET"
export TONE="$TONE"

# Heartbeat loop — every 6 hours
(while true; do
  sleep 21600
  UPTIME=$(python3 -c "print(int(open('/proc/uptime').read().split()[0])//3600)")
  curl -sf -X POST "${AIFREDO_API}/api/sdk/heartbeat" \
    -H "Content-Type: application/json" \
    -d "{\"license_key\":\"${LICENSE_KEY}\",\"version\":\"1.0.0\",\"uptime_hours\":${UPTIME}}" \
    > /dev/null 2>&1
  echo "💓 Heartbeat sent at $(date)"
done) &

exec "$@"
