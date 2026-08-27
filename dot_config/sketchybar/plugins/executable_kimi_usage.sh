#!/bin/bash

set -o pipefail

credential="$HOME/.zshrc.local"

[ -r "$credential" ] || exit 1

# SketchyBar does not inherit variables from interactive shells.
# shellcheck disable=SC1090
. "$credential" >/dev/null 2>&1

api_key="${KIMI_API_KEY:-}"
[ -n "$api_key" ] || exit 1

response="$({
	printf 'header = "Authorization: Bearer %s"\n' "$api_key"
	printf 'url = "https://api.kimi.ai/coding/v1/usages"\n'
	printf 'silent\nshow-error\nmax-time = 10\n'
} | /usr/bin/curl --config -)" || exit 1

printf '%s' "$response" | /usr/bin/jq -ce '{
	used: (.usage.used | tonumber),
	remaining: (.usage.remaining | tonumber),
	limit: (.usage.limit | tonumber),
	reset_at: .usage.resetTime
}'
