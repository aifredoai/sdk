#!/bin/bash
set -e

AIFREDO_API="${AIFREDO_API:-https://aifredo.chat}"
LICENSE_KEY="${FRED_LICENSE_KEY}"
SOUL_PATH="/app/backend/.deer-flow/agents/fred/SOUL.md"
CONFIG_PATH="/app/backend/.deer-flow/agents/fred/config.yaml"

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

VALID=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get(valid,false))")

if [ "$VALID" != "True" ] && [ "$VALID" != "true" ]; then
  echo "❌ Invalid license key — starting in demo mode"
  exec "$@"
fi

AGENT_NAME=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[fred][agent_name])")
BUSINESS_NAME=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[fred][business_name])")
BUSINESS_DESC=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[fred][business_description])")
TARGET_MARKET=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[fred][target_market])")
TONE=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[fred][tone])")

echo "✅ License valid — configuring Fred for: $BUSINESS_NAME"

mkdir -p "$(dirname $SOUL_PATH)"

cat > "$SOUL_PATH" << SOUL
# ${AGENT_NAME} — AI Business Development Agent

## Identity
You are ${AGENT_NAME}, the dedicated AI business development agent for ${BUSINESS_NAME}.

## About the Business
${BUSINESS_DESC}

## Target Market
${TARGET_MARKET}

## Tone
${TONE}

## Your Role
You handle the full sales development cycle:
- Find and research prospects matching the target market
- Write personalised outreach emails
- Follow up on leads
- Book meetings via Google Calendar
- Manage the prospect pipeline
- Generate research reports and pipeline summaries

## Rules
- Always represent ${BUSINESS_NAME} professionally
- Never make up information about the business
- If you are unsure about something, say so
- Keep outreach concise and value-focused
SOUL

echo "📝 SOUL.md written for ${BUSINESS_NAME}"

exec "$@"
