#!/bin/bash
# Audit Loop Stop Hook
# Blocks session exit while an audit-loop is active.
# Registered in: ~/dotfiles/claude/settings.json
#
# Enforcement policy:
#   Normal operation: only explicit cancellation can bypass the loop.
#   Abnormal recovery (documented safety valves, not user bypass paths):
#     - Staleness: state >2h old from crashed/abandoned session -> approve + cleanup
#     - Emergency ceiling: 10 total blocks -> approve (prevents permanent trap)
#
# Fail-open: every code path outputs {"decision":"approve"} or {"decision":"block"}.

approve() {
  echo '{"decision":"approve"}'
}

main() {
  # --- Dependency check ---
  command -v jq >/dev/null 2>&1 || { approve; return; }

  # --- Read hook input from stdin ---
  HOOK_INPUT=$(cat)

  # --- Guard: stop_hook_active prevents infinite recursion ---
  STOP_HOOK_ACTIVE=$(echo "$HOOK_INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
  if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    approve; return
  fi

  # --- Resolve state file path: normalize to repo root (matches update-state.sh) ---
  CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // ""' 2>/dev/null)
  if [ -z "$CWD" ]; then
    CWD=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
    echo "Warning: hook input missing .cwd, falling back to ${CWD}" >&2
  else
    # Normalize cwd to repo root (cwd may be a subdirectory)
    CWD=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
  fi
  STATE_FILE="${CWD}/.claude/audit-loop.local.json"

  # --- Guard: state file must exist ---
  if [ ! -f "$STATE_FILE" ]; then
    approve; return
  fi

  # --- Parse state (read file once, extract fields individually — no eval) ---
  STATE_JSON=$(cat "$STATE_FILE" 2>/dev/null) || { approve; return; }
  ACTIVE=$(echo "$STATE_JSON" | jq -r '.active // false' 2>/dev/null) || { approve; return; }
  CANCELLED=$(echo "$STATE_JSON" | jq -r '.cancelled // false' 2>/dev/null) || { approve; return; }
  PHASE=$(echo "$STATE_JSON" | jq -r '.phase // 0' 2>/dev/null) || { approve; return; }
  PHASE_NAME=$(echo "$STATE_JSON" | jq -r '.phase_name // "unknown"' 2>/dev/null) || { approve; return; }
  STEP=$(echo "$STATE_JSON" | jq -r '.step // 0' 2>/dev/null) || { approve; return; }
  TOTAL_BLOCKS=$(echo "$STATE_JSON" | jq -r '.total_blocks // 0' 2>/dev/null) || { approve; return; }
  PLAN_STEP_NAME=$(echo "$STATE_JSON" | jq -r '.plan_step_name // "unknown"' 2>/dev/null) || { approve; return; }
  LAST_TRANSITION=$(echo "$STATE_JSON" | jq -r '.last_transition // ""' 2>/dev/null) || { approve; return; }

  # --- Guard: not active or cancelled ---
  if [ "$ACTIVE" != "true" ] || [ "$CANCELLED" = "true" ]; then
    rm -f "$STATE_FILE"
    approve; return
  fi

  # --- Guard: phase 5 (summary/done) ---
  if [ "$PHASE" = "5" ]; then
    rm -f "$STATE_FILE"
    approve; return
  fi

  # --- Staleness check (abnormal recovery: crashed/abandoned session cleanup) ---
  if [ -n "$LAST_TRANSITION" ]; then
    NOW_EPOCH=$(date +%s)
    # Cross-platform epoch parsing (try GNU date, then BSD date)
    LAST_EPOCH=$(date -d "$LAST_TRANSITION" +%s 2>/dev/null \
      || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_TRANSITION" +%s 2>/dev/null \
      || echo "")
    # If date parsing failed, skip staleness check (don't clean up what we can't measure)
    if [ -n "$LAST_EPOCH" ]; then
      AGE=$((NOW_EPOCH - LAST_EPOCH))
      if [ "$AGE" -gt 7200 ] 2>/dev/null; then
        echo "Audit-loop state is ${AGE}s old (stale session). Cleaning up." >&2
        rm -f "$STATE_FILE"
        approve; return
      fi
    fi
  fi

  # --- Emergency ceiling (abnormal recovery: prevents permanent trap) ---
  if [ "$TOTAL_BLOCKS" -ge 10 ] 2>/dev/null; then
    echo "EMERGENCY: audit-loop hit 10 total blocks. Approving exit." >&2
    echo "Next time, say 'cancel the audit loop' to exit cleanly." >&2
    rm -f "$STATE_FILE"
    approve; return
  fi

  # --- Increment total_blocks and update last_transition ---
  NEW_BLOCKS=$((TOTAL_BLOCKS + 1))
  TEMP_FILE="${STATE_FILE}.tmp.$$"
  jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    ".total_blocks = ${NEW_BLOCKS} | .last_transition = \$ts" \
    "$STATE_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$STATE_FILE" \
    || { rm -f "$TEMP_FILE"; approve; return; }

  # --- Build phase-aware continuation prompt ---
  case $PHASE in
    1) INSTRUCTIONS="Phase 1 (Test-First Implementation), step ${STEP}/4. Continue the audit-loop. If make validate keeps failing after 3 attempts within a single run, STOP and report errors to the user." ;;
    2) INSTRUCTIONS="Phase 2 (Self-Audit), step ${STEP}. Spawn the review sub-agent and fix P0/P1 findings." ;;
    3) INSTRUCTIONS="Phase 3 (Codex CLI Audit), step ${STEP}/10. Run or re-run the Codex audit, triage findings, and fix. If P0s persist after 2 Codex rounds, STOP and report to user." ;;
    4) INSTRUCTIONS="Phase 4 (Commit & Document), step ${STEP}. Commit changes, update progress, and write the handover doc." ;;
    *) approve; return ;;
  esac

  REASON="Audit-loop is active for: ${PLAN_STEP_NAME}

${INSTRUCTIONS}

Read .claude/audit-loop.local.json to confirm current phase/step, then continue the audit-loop skill. Update the state file at each phase boundary (the SKILL.md has the commands). To cancel, say 'cancel the audit loop'."

  SYSTEM_MSG="Audit loop block ${NEW_BLOCKS}/10 | Phase ${PHASE} (${PHASE_NAME}) step ${STEP} | ${PLAN_STEP_NAME}"

  jq -n --arg reason "$REASON" --arg msg "$SYSTEM_MSG" \
    '{"decision":"block","reason":$reason,"systemMessage":$msg}'
}

# --- Outer wrapper: guarantees JSON output on every path ---
# NOTE: stderr is NOT suppressed here — warning messages (staleness, emergency)
# from main() are intentionally visible to Claude Code's hook stderr output.
OUTPUT=$(main) || true
if [ -z "$OUTPUT" ]; then
  echo '{"decision":"approve"}'
else
  echo "$OUTPUT"
fi
