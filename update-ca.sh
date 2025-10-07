#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${PORT:-3000}"
BASE_URL="${BASE_URL:-http://localhost:${PORT}}"

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") 0x<40-hex> [BASE_URL]" >&2
  echo "Example: $(basename "$0") 0x1234567890abcdef1234567890abcdef12345678 http://localhost:3000" >&2
  exit 1
fi

ADDR="$1"
if [ $# -ge 2 ]; then
  BASE_URL="$2"
fi

# Load .env if present
if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ROOT_DIR/.env"
  set +a
fi

ADMIN_KEY_VALUE="${ADMIN_KEY:-}"

if ! [[ "$ADDR" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
  echo "Error: invalid address format: $ADDR" >&2
  exit 2
fi

if [ -z "$ADMIN_KEY_VALUE" ]; then
  echo "Error: ADMIN_KEY not set (define it in .env)" >&2
  exit 3
fi

echo "Updating contract to $ADDR at ${BASE_URL}..."
RESP=$(curl -sS -X POST "${BASE_URL}/api/contract" \
  -H 'Content-Type: application/json' \
  -H "x-admin-key: ${ADMIN_KEY_VALUE}" \
  -d "{\"contract\":\"${ADDR}\"}")

echo "$RESP"

if [[ "$RESP" != *"\"contract\":"* ]]; then
  echo "Update may have failed." >&2
  exit 4
fi

echo "Done."


