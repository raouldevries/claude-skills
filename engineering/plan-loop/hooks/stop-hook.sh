#!/bin/bash
# Plan Loop Stop Hook
# Blocks session exit while a plan-loop refinement cycle is active.
# Registered in: ~/dotfiles/claude/settings.json
#
# Enforcement policy:
#   Normal operation: only explicit cancellation or convergence can end the loop.
#   Abnormal recovery (safety valves, not user bypass paths):
#     - Staleness: state >4h old from crashed/abandoned session -> approve + cleanup
#     - Emergency ceiling: 20 total blocks -> approve (prevents permanent trap)
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
  STATE_FILE="${CWD}/.claude/plan-loop.local.json"

  # --- Guard: state file must exist ---
  if [ ! -f "$STATE_FILE" ]; then
    approve; return
  fi

  # --- Parse state (read file once, extract fields individually — no eval) ---
  STATE_JSON=$(cat "$STATE_FILE" 2>/dev/null) || { approve; return; }
  ACTIVE=$(echo "$STATE_JSON" | jq -r '.active // false' 2>/dev/null) || { approve; return; }
  CANCELLED=$(echo "$STATE_JSON" | jq -r '.cancelled // false' 2>/dev/null) || { approve; return; }
  CONVERGED=$(echo "$STATE_JSON" | jq -r '.converged // false' 2>/dev/null) || { approve; return; }
  ROUND=$(echo "$STATE_JSON" | jq -r '.round // 0' 2>/dev/null) || { approve; return; }
  PHASE=$(echo "$STATE_JSON" | jq -r '.phase // "unknown"' 2>/dev/null) || { approve; return; }
  TOTAL_BLOCKS=$(echo "$STATE_JSON" | jq -r '.total_blocks // 0' 2>/dev/null) || { approve; return; }
  PLAN_NAME=$(echo "$STATE_JSON" | jq -r '.plan_name // "unknown"' 2>/dev/null) || { approve; return; }
  LAST_TRANSITION=$(echo "$STATE_JSON" | jq -r '.last_transition // ""' 2>/dev/null) || { approve; return; }
  STATE_SESSION_ID=$(echo "$STATE_JSON" | jq -r '.session_id // ""' 2>/dev/null) || { approve; return; }
  HOOK_SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""' 2>/dev/null) || { approve; return; }

  # --- Guard: not active or cancelled ---
  if [ "$ACTIVE" != "true" ] || [ "$CANCELLED" = "true" ]; then
    rm -f "$STATE_FILE"
    approve; return
  fi

  # --- Guard: converged ---
  if [ "$CONVERGED" = "true" ]; then
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
      if [ "$AGE" -gt 14400 ] 2>/dev/null; then
        echo "Plan-loop state is ${AGE}s old (stale session). Cleaning up." >&2
        rm -f "$STATE_FILE"
        approve; return
      fi
    fi
  fi

  # --- Emergency ceiling (abnormal recovery: prevents permanent trap) ---
  if [ "$TOTAL_BLOCKS" -ge 20 ] 2>/dev/null; then
    echo "EMERGENCY: plan-loop hit 20 total blocks. Approving exit." >&2
    echo "Next time, say 'cancel the plan loop' to exit cleanly." >&2
    rm -f "$STATE_FILE"
    approve; return
  fi

  # --- Session scoping: prevent parallel session hijacking ---

  # Claimed loop: only block the owning session, full continuation prompt
  if [ -n "$STATE_SESSION_ID" ]; then
    if [ "$HOOK_SESSION_ID" != "$STATE_SESSION_ID" ]; then
      approve; return
    fi

    NEW_BLOCKS=$((TOTAL_BLOCKS + 1))
    TEMP_FILE="${STATE_FILE}.tmp.$$"
    jq --argjson nb "$NEW_BLOCKS" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '.total_blocks = $nb | .last_transition = $ts' \
      "$STATE_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$STATE_FILE" \
      || { rm -f "$TEMP_FILE"; approve; return; }

    case "$PHASE" in
      draft)      INSTRUCTIONS="Phase: Draft (round ${ROUND}). Continue drafting the plan document. Use the /make-plan discovery protocol if this is round 1, or revise based on prior round's FIX findings. IMPORTANT: Only edit the plan .md file — do NOT write implementation code." ;;
      self-audit) INSTRUCTIONS="Phase: Self-Audit (round ${ROUND}). Spawn the review sub-agent to audit the plan for structural issues using the triage rubric severity definitions. Read codebase files for verification only — do NOT modify them." ;;
      codex-audit) INSTRUCTIONS="Phase: Codex Audit (round ${ROUND}). Run \`codex exec --sandbox read-only\` with the plan audit prompt and assembled context. Do NOT implement any plan steps." ;;
      triage)     INSTRUCTIONS="Phase: Triage (round ${ROUND}). Triage each Codex finding using mandatory context rebuttal (FIX/DISMISS/SCOPE-OUT with evidence). Apply round-aware severity threshold. Do NOT implement any plan steps." ;;
      fix)        INSTRUCTIONS="Phase: Fix (round ${ROUND}). Apply all ABOVE-threshold FIX findings to the plan document text. 'Fix' means editing the plan .md file — NOT implementing code. Once all plan text fixes are applied, compress round 1 context (see Inter-Round Context Compression in SKILL.md), then increment to round 2 with 'update-state.sh round 2' and skip to codex-audit. If this is already round 2, force converge with accepted risk or escalate P0s to the user." ;;
      *) approve; return ;;
    esac

    REASON="Plan-loop is active for: ${PLAN_NAME}

${INSTRUCTIONS}

Read .claude/plan-loop.local.json to confirm current round/phase, then continue the plan-loop skill. Update the state file at each phase boundary (the SKILL.md has the commands). To cancel, say 'cancel the plan loop'."

    SYSTEM_MSG="Plan loop block ${NEW_BLOCKS}/20 | Round ${ROUND}/2, phase: ${PHASE} | ${PLAN_NAME}"

    jq -n --arg reason "$REASON" --arg msg "$SYSTEM_MSG" \
      '{"decision":"block","reason":$reason,"systemMessage":$msg}'
    return
  fi

  # Unclaimed loop: one-shot block with claim-only reason, approve on repeat
  LAST_BLOCKED=$(echo "$STATE_JSON" | jq -r '.last_blocked_session_id // ""' 2>/dev/null)

  if [ -n "$HOOK_SESSION_ID" ] && [ "$HOOK_SESSION_ID" = "$LAST_BLOCKED" ]; then
    # Same session blocked again without claiming → not the owner → approve
    approve; return
  fi

  # First block for this session: record and block with minimal claim reason
  NEW_BLOCKS=$((TOTAL_BLOCKS + 1))
  TEMP_FILE="${STATE_FILE}.tmp.$$"
  jq --argjson nb "$NEW_BLOCKS" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg lbs "$HOOK_SESSION_ID" \
    '.total_blocks = $nb | .last_transition = $ts | .last_blocked_session_id = $lbs' \
    "$STATE_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$STATE_FILE" \
    || { rm -f "$TEMP_FILE"; approve; return; }

  REASON="A plan-loop is active for: ${PLAN_NAME}, but has no session owner yet.

If you are running /plan-loop, claim this loop now:
  ~/.claude/skills/plan-loop/hooks/update-state.sh claim ${HOOK_SESSION_ID}
Then read .claude/plan-loop.local.json and continue the plan-loop skill.

If you are NOT running /plan-loop, proceed with your current task — your next exit will be approved automatically."

  SYSTEM_MSG="Plan loop (unclaimed) | ${PLAN_NAME}"

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
