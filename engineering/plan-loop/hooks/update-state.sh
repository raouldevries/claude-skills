#!/bin/bash
# Centralized state management for plan-loop stop hook.
# All state file operations go through this script to ensure
# consistent path resolution and atomic writes.
#
# Usage:
#   update-state.sh init <plan_name>        # create state file (round 1, phase "draft")
#   update-state.sh round <round_num>       # transition to new round, reset phase to "self-audit"
#   update-state.sh phase <phase_name>      # transition phase within current round
#   update-state.sh converge                # mark plan as converged
#   update-state.sh claim <session_id>       # register owning session (from stop hook block reason)
#   update-state.sh cancel                  # cancel loop and delete state file
#   update-state.sh cleanup                 # delete state file silently
#
# Phases (per round): draft, self-audit, codex-audit, triage, fix

command -v jq >/dev/null 2>&1 || exit 0

# Resolve project root (single source of truth for state file path)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
STATE_FILE="${ROOT}/.claude/plan-loop.local.json"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TEMP="${STATE_FILE}.tmp.$$"

case "$1" in
  init)
    PLAN_NAME="$2"
    if [ -f "$STATE_FILE" ]; then
      EXISTING_ACTIVE=$(jq -r '.active // false' "$STATE_FILE" 2>/dev/null)
      if [ "$EXISTING_ACTIVE" = "true" ]; then
        echo "Error: plan loop already active. Run 'update-state.sh cancel' first." >&2
        exit 1
      fi
    fi
    mkdir -p "${ROOT}/.claude"
    jq -n --arg name "$PLAN_NAME" --arg ts "$TS" \
      '{active:true, round:1, phase:"draft", converged:false, total_blocks:0, plan_name:$name, session_id:"", last_blocked_session_id:"", started_at:$ts, last_transition:$ts, cancelled:false}' \
      > "$TEMP" && mv "$TEMP" "$STATE_FILE" || { rm -f "$TEMP"; exit 1; }
    ;;
  round)
    [ -f "$STATE_FILE" ] || exit 0
    ROUND="$2"
    if ! echo "$ROUND" | grep -qE '^[1-9][0-9]*$'; then
      echo "Error: round subcommand requires a positive integer argument." >&2
      exit 1
    fi
    CURRENT=$(jq -r '.round // 0' "$STATE_FILE" 2>/dev/null)
    if [ "$ROUND" -le "$CURRENT" ] 2>/dev/null; then
      echo "Error: round $ROUND is not greater than current round $CURRENT." >&2
      exit 1
    fi
    if [ "$ROUND" -gt 2 ] 2>/dev/null; then
      echo "Error: max round is 2." >&2
      exit 1
    fi
    jq --arg ts "$TS" --argjson round "$ROUND" \
      '.round=$round | .phase="self-audit" | .last_transition=$ts' \
      "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" || { rm -f "$TEMP"; exit 1; }
    ;;
  phase)
    [ -f "$STATE_FILE" ] || exit 0
    PHASE_NAME="$2"
    case "$PHASE_NAME" in
      draft|self-audit|codex-audit|triage|fix) ;;
      *)
        echo "Error: unknown phase '${PHASE_NAME}'. Valid: draft, self-audit, codex-audit, triage, fix." >&2
        exit 1
        ;;
    esac
    jq --arg ts "$TS" --arg pn "$PHASE_NAME" \
      '.phase=$pn | .last_transition=$ts' \
      "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" || { rm -f "$TEMP"; exit 1; }
    ;;
  converge)
    [ -f "$STATE_FILE" ] || exit 0
    jq --arg ts "$TS" \
      '.converged=true | .last_transition=$ts' \
      "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" || { rm -f "$TEMP"; exit 1; }
    ;;
  cancel)
    [ -f "$STATE_FILE" ] || { echo "No active plan loop found."; exit 0; }
    # Set cancelled flag first (race condition safety net for hook)
    jq '.cancelled=true' "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" \
      || { rm -f "$TEMP"; echo "Warning: could not set cancelled flag, deleting anyway." >&2; }
    # Report and delete
    jq -r '"Cancelled plan loop \"\(.plan_name)\" at round \(.round), phase \(.phase)"' "$STATE_FILE" 2>/dev/null
    rm -f "$STATE_FILE"
    ;;
  claim)
    [ -f "$STATE_FILE" ] || { echo "Error: no active plan loop to claim." >&2; exit 1; }
    SID="$2"
    if [ -z "$SID" ]; then
      echo "Error: claim subcommand requires a session_id argument." >&2
      exit 1
    fi
    CURRENT_SID=$(jq -r '.session_id // ""' "$STATE_FILE" 2>/dev/null)
    if [ -n "$CURRENT_SID" ] && [ "$CURRENT_SID" != "$SID" ]; then
      echo "Error: plan loop already claimed by session ${CURRENT_SID}." >&2
      exit 1
    fi
    jq --arg sid "$SID" '.session_id = $sid' \
      "$STATE_FILE" > "$TEMP" && mv "$TEMP" "$STATE_FILE" || { rm -f "$TEMP"; exit 1; }
    echo "Session ${SID} claimed plan loop \"$(jq -r '.plan_name' "$STATE_FILE" 2>/dev/null)\"."
    ;;
  cleanup)
    rm -f "$STATE_FILE"
    ;;
  *)
    echo "Error: unknown subcommand '$1'. Valid: init, round, phase, converge, cancel, claim, cleanup." >&2
    exit 1
    ;;
esac
