#!/usr/bin/env bash
FILE="$HOME/.cache/target"

if [[ -f "$FILE" ]]; then
    printf "🎯 %-15s" "$(cat "$FILE")"
else
    printf "🎯 %-15s" "NONE"
fi
