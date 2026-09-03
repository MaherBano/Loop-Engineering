#!/usr/bin/env bash
# OpenCode approach: Parallel fix-and-review engine using isolated worktrees, & fan-out, and reviewer exit codes
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PYTHON_BIN="$(command -v python3 || command -v python || command -v py)"

WORKTREE_BASE_DIR="/tmp/p05-worktrees-$$"
mkdir -p "$WORKTREE_BASE_DIR"

echo "================================================================"
echo " Starting Parallel Fix-and-Review Workflow"
echo " Working directory: $SCRIPT_DIR"
echo " Python binary: $PYTHON_BIN"
echo " Isolation scratch space: $WORKTREE_BASE_DIR"
echo "================================================================"

CANDIDATES=("good-fix" "bad-recursive" "bad-unfixed")
PIDS=()
RESULTS_DIR="$WORKTREE_BASE_DIR/results"
mkdir -p "$RESULTS_DIR"

# Step 1: Fan out parallel fix draft and review in isolated checkouts
for CANDIDATE in "${CANDIDATES[@]}"; do
    (
        CANDIDATE_DIR="$WORKTREE_BASE_DIR/$CANDIDATE"
        mkdir -p "$CANDIDATE_DIR"
        cp "$SCRIPT_DIR/math_utils.py" "$CANDIDATE_DIR/math_utils.py"

        # Apply candidate modification
        case "$CANDIDATE" in
            "good-fix")
                # Correct fix: return a - b
                sed -i 's/return b - a/return a - b/g' "$CANDIDATE_DIR/math_utils.py"
                ;;
            "bad-recursive")
                # Bad fix: infinite recursion
                sed -i 's/return b - a/return subtract_numbers(b, a)/g' "$CANDIDATE_DIR/math_utils.py"
                ;;
            "bad-unfixed")
                # Bug unfixed: still returns b - a
                sed -i 's/def subtract_numbers(a, b):/def subtract_numbers(a, b):\n    # Reviewed - leaving b - a/' "$CANDIDATE_DIR/math_utils.py"
                ;;
        esac

        # Step 2: Run Reviewer agent/checker against the candidate checkout
        REVIEW_OUTPUT_FILE="$RESULTS_DIR/${CANDIDATE}.json"
        EXIT_CODE=0
        "$PYTHON_BIN" "$SCRIPT_DIR/reviewer.py" "$CANDIDATE_DIR/math_utils.py" > "$REVIEW_OUTPUT_FILE" 2>&1 || EXIT_CODE=$?

        echo "$EXIT_CODE" > "$RESULTS_DIR/${CANDIDATE}.exitcode"
    ) &
    PIDS+=($!)
done

# Step 3: Wait for all parallel candidate evaluations to complete
echo "Waiting for all $((${#CANDIDATES[@]})) candidate evaluations to complete..."
for PID in "${PIDS[@]}"; do
    wait "$PID"
done

echo "All candidate reviews finished."
echo ""
echo "================================================================"
echo " Evaluation Verdicts"
echo "================================================================"

TOTAL=0
PASSED=0
FAILED=0

for CANDIDATE in "${CANDIDATES[@]}"; do
    TOTAL=$((TOTAL + 1))
    EXIT_CODE="$(cat "$RESULTS_DIR/${CANDIDATE}.exitcode")"
    REVIEW_JSON="$RESULTS_DIR/${CANDIDATE}.json"

    VERDICT=$("$PYTHON_BIN" -c "import sys, json; data=json.load(open(sys.argv[1], encoding='utf-8')); print(data.get('verdict', 'UNKNOWN'))" "$REVIEW_JSON" 2>/dev/null || echo "FAIL")

    if [ "$EXIT_CODE" -eq 0 ] && [ "$VERDICT" == "PASS" ]; then
        PASSED=$((PASSED + 1))
        STATUS="[PASS]"
    else
        FAILED=$((FAILED + 1))
        STATUS="[FAIL]"
    fi

    printf "%-18s %-8s (Exit Code: %d)\n" "$CANDIDATE:" "$STATUS" "$EXIT_CODE"
    echo "  Review Details:"
    sed 's/^/    /' "$REVIEW_JSON"
    echo "----------------------------------------------------------------"
done

echo "Summary: Total: $TOTAL | Passed: $PASSED | Failed: $FAILED"
echo "================================================================"

# Cleanup
rm -rf "$WORKTREE_BASE_DIR"

if [ "$PASSED" -ge 1 ]; then
    echo "Workflow completed successfully: at least 1 candidate fix approved."
    exit 0
else
    echo "Workflow completed: no candidate passed review."
    exit 1
fi
