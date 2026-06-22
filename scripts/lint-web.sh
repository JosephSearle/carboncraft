#!/usr/bin/env bash
# PostToolUse hook: runs Biome check --apply on the edited TypeScript/TSX file.
# Input: event JSON on stdin with .tool_input.file_path

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

[[ -z "$FILE_PATH" ]] && exit 0
[[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && exit 0

if command -v biome >/dev/null 2>&1; then
  biome check --apply --no-errors-on-unmatched "$FILE_PATH" 2>&1 || true
elif [ -f "$(pwd)/node_modules/.bin/biome" ]; then
  "$(pwd)/node_modules/.bin/biome" check --apply --no-errors-on-unmatched "$FILE_PATH" 2>&1 || true
fi
