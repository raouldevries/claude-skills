#!/bin/bash
# Centralized state management for audit-loop stop hook.
# All state file operations go through this script to ensure
# consistent path resolution.
#
# Usage:
#   update-state.sh init <step_name>                          # create state file
#   update-state.sh phase <phase_num> <phase_name> <step_num> # phase transition
#   update-state.sh step <step_num>                           # step update
#   update-state.sh cancel                                    # cancel loop
#   update-state.sh cleanup                                   # delete state file

command -v jq >/dev/null 2>&1 || exit 0

# Resolve project root (single source of truth for state file path)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
STATE_FILE="${ROOT}/.claude/audit-loop.local.json"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TEMP="${STATE_FILE}.tmp.$$"

case "$1" in
  init)
    STEP_NAME="$2"
    if [ -f "$STATE_FILE" ]; then
      EXISTING_ACTIVE=$(jq -r '.active // false' "$STATE_FILE" 2>/dev/null)
      if [ "$EXISTING_ACTIVE" = "true" ]; then
        echo "Error: audit loop already active. Run 'update-state.sh cancel' first." >&2
        exit 1
      fi
    fi
    mkdir -p "${ROOT}/.claude"
    jq -n --arg name "$STEP_NAME" --arg ts "$TS" \
      '{active:true, phase:1, phase_name:"test-first-implementation", step:1, total_blocks:0, started_at:$ts, last_transition:$ts, plan_step_name:$name, cancelled:false}' \
      > "$STATE_FILE"
    ;;
  phase)
    [ -f "$STATE_FILE" ] || exit 0
    PHASE="$2"; PHASE_NAME="$3"; STEP="$4"
    jq --arg ts "$TS" --arg pn "$PHASE_NAME" \
      --argjson phase "$PHASE" --argjson step "$STEP" \
      '.phase=$phase | .phase_name=$pn | .step=$step | .last_transition=$ts' \
      "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" || rm -f "$TEMP"
    ;;
  step)
    [ -f "$STATE_FILE" ] || exit 0
    STEP="$2"
    jq --arg ts "$TS" --argjson step "$STEP" \
      '.step=$step | .last_transition=$ts' \
      "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" || rm -f "$TEMP"
    ;;
  cancel)
    [ -f "$STATE_FILE" ] || { echo "No active audit loop found."; exit 0; }
    # Set cancelled flag first (race condition safety net for hook)
    jq '.cancelled=true' "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" || true
    # Report and delete
    jq -r '"Cancelled audit loop at Phase \(.phase) (\(.phase_name)), step \(.step)"' "$STATE_FILE" 2>/dev/null
    rm -f "$STATE_FILE"
    ;;
  cleanup)
    rm -f "$STATE_FILE"
    ;;
esac
