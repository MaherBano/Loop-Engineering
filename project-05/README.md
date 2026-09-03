# Project 05: Parallel Fix-and-Review Workflow & The Engine vs. Loop Distinction

**Difficulty:** Medium to Hard  
**Concepts Used:** Dynamic Workflows Interlude, Worktree Isolation (Concept 8), Maker-Checker Loop (Concept 11), Slash Commands & Workflows (Concept 9)

---

## Overview

In **Project 04**, we built a single maker-checker loop where an implementer drafted a fix in a single worktree and a reviewer evaluated the change.

In **Project 05**, we **codify** that entire body into a single automated, multi-candidate execution system. Instead of step-by-step interactive prompting, a single command orchestrates:
1. **Parallel fan-out** of multiple candidate fixes across isolated worktree environments.
2. **Automated grading** of each candidate using a strict reviewer checker.
3. **Structured verdict aggregation** reporting PASS / FAIL statuses and detailed diagnostics.

We implement this in two distinct ways:
- **Claude Code Approach:** Dynamic multi-agent workflow (`fix-review-workflow.js` & `/parallel-fix-review` command).
- **OpenCode Approach:** POSIX shell script (`run-candidates.sh`) leveraging subshell fan-out (`&`), synchronization (`wait`), and reviewer process exit codes.

Finally, we test session isolation and articulate the fundamental conceptual difference between an **Engine** and a **Loop**.

---

## Architecture & Candidate Set

The target bug is located in `math_utils.py`, where `subtract_numbers(a, b)` incorrectly returns `b - a` instead of `a - b`.

Three candidate implementations are evaluated concurrently:

| Candidate ID | Intended Strategy | Expected Outcome | Reviewer Verdict |
| :--- | :--- | :--- | :--- |
| `good-fix` | Changes `return b - a` to `return a - b` | Correct logic | **PASS** (Exit Code 0) |
| `bad-recursive` | Changes `return b - a` to `return subtract_numbers(b, a)` | Infinite recursion bug | **FAIL** (Exit Code 1) |
| `bad-unfixed` | Retains `return b - a` unchanged (adds comment only) | Bug remains unfixed | **FAIL** (Exit Code 1) |

---

## Implementations

### 1. Claude Code Approach (Dynamic Workflow)

- **Workflow Script:** `fix-review-workflow.js` (and `.claude/workflows/parallel-fix-review.js`)
- **Slash Command:** `.claude/commands/parallel-fix-review.md` (`/parallel-fix-review`)

```javascript
export const meta = {
  name: 'parallel-fix-review',
  description: 'Draft fixes for multiple candidates in parallel worktrees and grade each',
  phases: [
    { title: 'Fix', detail: 'Apply candidate fixes in isolated worktrees' },
    { title: 'Review', detail: 'Grade each candidate with reviewer checker' },
  ],
}

// Phase 1: Parallel draft in isolated worktrees
phase('Fix')
const fixes = await parallel(
  CANDIDATES.map(candidate => () =>
    agent(candidate.prompt, {
      label: `fix:${candidate.id}`,
      phase: 'Fix',
      schema: FIX_SCHEMA,
      isolation: 'worktree',
    })
  )
)

// Phase 2: Pipeline grading per candidate as soon as fix is ready
phase('Review')
const results = await pipeline(
  CANDIDATES.map((c, i) => ({ candidate: c, fix: fixes[i] })),
  async ({ candidate, fix }) => {
    const review = await agent(reviewPrompt(fix), {
      label: `review:${candidate.id}`,
      phase: 'Review',
      schema: REVIEW_SCHEMA,
    })
    return { candidate_id: candidate.id, fix_result: fix, review_result: review }
  }
)
```

### 2. OpenCode Approach (Shell Script)

- **Script File:** `run-candidates.sh`
- **Reviewer Agent:** `reviewer.py`

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Fan out candidate fixes into isolated directories
for CANDIDATE in "${CANDIDATES[@]}"; do
    (
        CANDIDATE_DIR="$WORKTREE_BASE_DIR/$CANDIDATE"
        mkdir -p "$CANDIDATE_DIR"
        cp "$SCRIPT_DIR/math_utils.py" "$CANDIDATE_DIR/math_utils.py"

        # Apply candidate patch
        apply_patch "$CANDIDATE" "$CANDIDATE_DIR/math_utils.py"

        # Run reviewer checker
        EXIT_CODE=0
        python3 reviewer.py "$CANDIDATE_DIR/math_utils.py" > "$RESULTS_DIR/${CANDIDATE}.json" 2>&1 || EXIT_CODE=$?
        echo "$EXIT_CODE" > "$RESULTS_DIR/${CANDIDATE}.exitcode"
    ) &
    PIDS+=($!)
done

# 2. Synchronize background tasks
for PID in "${PIDS[@]}"; do
    wait "$PID"
done

# 3. Aggregate and display verdicts
```

---

## Execution Verification (Run Twice)

The OpenCode workflow script was executed twice consecutively to verify deterministic, repeatable execution:

### Run #1 Execution Output

```text
================================================================
 Starting Parallel Fix-and-Review Workflow
 Working directory: /c/Users/AANIQ/loop engineering/project-05
 Python binary: /c/Program Files/Python314/python
 Isolation scratch space: /tmp/p05-worktrees-829
================================================================
Waiting for all 3 candidate evaluations to complete...
All candidate reviews finished.

================================================================
 Evaluation Verdicts
================================================================
good-fix:          [PASS]   (Exit Code: 0)
  Review Details:
    {
      "verdict": "PASS",
      "reasons": [
        "✓ Correct: subtract_numbers returns a - b",
        "✓ Docstring is accurate",
        "✓ add_numbers function unchanged"
      ]
    }
----------------------------------------------------------------
bad-recursive:     [FAIL]   (Exit Code: 1)
  Review Details:
    {
      "verdict": "FAIL",
      "reasons": [
        "CRITICAL: Recursive call detected - will cause infinite recursion: return subtract_numbers(b, a)",
        "The fix must directly return a - b, not recursively call itself"
      ]
    }
----------------------------------------------------------------
bad-unfixed:       [FAIL]   (Exit Code: 1)
  Review Details:
    {
      "verdict": "FAIL",
      "reasons": [
        "CRITICAL: Bug NOT fixed - still returns b - a instead of a - b"
      ]
    }
----------------------------------------------------------------
Summary: Total: 3 | Passed: 1 | Failed: 2
================================================================
Workflow completed successfully: at least 1 candidate fix approved.
```

### Run #2 Execution Output

```text
================================================================
 Starting Parallel Fix-and-Review Workflow
 Working directory: /c/Users/AANIQ/loop engineering/project-05
 Python binary: /c/Program Files/Python314/python
 Isolation scratch space: /tmp/p05-worktrees-588
================================================================
Waiting for all 3 candidate evaluations to complete...
All candidate reviews finished.

================================================================
 Evaluation Verdicts
================================================================
good-fix:          [PASS]   (Exit Code: 0)
  Review Details:
    {
      "verdict": "PASS",
      "reasons": [
        "✓ Correct: subtract_numbers returns a - b",
        "✓ Docstring is accurate",
        "✓ add_numbers function unchanged"
      ]
    }
----------------------------------------------------------------
bad-recursive:     [FAIL]   (Exit Code: 1)
  Review Details:
    {
      "verdict": "FAIL",
      "reasons": [
        "CRITICAL: Recursive call detected - will cause infinite recursion: return subtract_numbers(b, a)",
        "The fix must directly return a - b, not recursively call itself"
      ]
    }
----------------------------------------------------------------
bad-unfixed:       [FAIL]   (Exit Code: 1)
  Review Details:
    {
      "verdict": "FAIL",
      "reasons": [
        "CRITICAL: Bug NOT fixed - still returns b - a instead of a - b"
      ]
    }
----------------------------------------------------------------
Summary: Total: 3 | Passed: 1 | Failed: 2
================================================================
Workflow completed successfully: at least 1 candidate fix approved.
```

---

## Proving Session Isolation

The interlude cautions that dynamic workflows and multi-agent scripts operate statelessly by default.

When tested in a sanitized, completely fresh shell (`env -i PATH="$PATH" HOME="$HOME" bash -c './run-candidates.sh'`):
- The workflow launches without access to previous in-memory state or session history.
- It re-evaluates all 3 candidates strictly against the base codebase.
- No memory of previous runs persists across session boundaries.

---

## Conceptual Distinction: Engine vs. Loop

A dynamic workflow or shell orchestration script is an **Engine**, not a **Loop**.

```
  ┌───────────────────────────────────────────────────────────┐
  │                        THE ENGINE                         │
  │  (One-shot Directed Acyclic Graph / Multi-Agent Fan-Out)  │
  │                                                           │
  │     [Candidate 1] ───► [Isolated Draft] ───► [Review] ──┐ │
  │     [Candidate 2] ───► [Isolated Draft] ───► [Review] ──┼─┼──► Verdicts & Exit
  │     [Candidate 3] ───► [Isolated Draft] ───► [Review] ──┘ │
  └───────────────────────────────────────────────────────────┘
```

An engine takes inputs, executes a dependency graph in parallel, computes a result, and halts. It is a **one-shot stateless transformer**.

To convert an **Engine** into an autonomous, self-sustaining **Loop**, two critical components are required:

```
                  ┌─────────────────────────────────┐
                  │          1. HEARTBEAT           │
                  │  (Cron / Recurring Timer / CI)  │
                  └────────────────┬────────────────┘
                                   │ fires
                                   ▼
  ┌──────────────────────────────────────────────────────────────┐
  │                         THE ENGINE                           │
  │               (Executes next unit of work)                   │
  └─────────────────┬──────────────────────────▲─────────────────┘
                    │ writes                   │ reads
                    ▼                          │ state
  ┌────────────────────────────────────────────┴─────────────────┐
  │                    2. PROGRESS FILE / SPINE                  │
  │            (Durable ledger: state.json / MEMORY.md)          │
  └──────────────────────────────────────────────────────────────┘
```

### 1. A Heartbeat (The Temporal Trigger)
- **What it is:** A periodic or event-driven mechanism that wakes up the system without human intervention.
- **Examples:** System cron, `CronCreate` (`0 */2 * * *`), an in-session timer (`/loop 5m`), GitHub webhook, or a file-system watcher.
- **Why it is necessary:** Without a heartbeat, the engine runs once and dies. The heartbeat provides the continuous rhythm that repeatedly invokes the engine.

### 2. A Progress File / State Spine (The Durable Memory)
- **What it is:** A persistent record on disk (e.g. `progress.json`, `state.sqlite`, `MEMORY.md`, or a work queue file) that survives session resets.
- **What agents write:**
  - IDs of candidates already attempted and their verdicts.
  - Failure reasons to prevent repeating the same mistake.
  - Iteration count and termination conditions (e.g., stopping when all tests pass).
  - Pointers to uncompleted work.
- **Why it is necessary:** Without a progress file, each tick of the heartbeat starts with total amnesia, blindly repeating candidate 1 over and over. The progress file gives the loop memory, state progression, and convergence.

---

## Success Criteria Checklist

- [x] **Single-command execution:** One command (`./run-candidates.sh` or `/parallel-fix-review`) executes the entire draft-and-review workflow across multiple candidates without step-by-step human prompting.
- [x] **Isolated environments:** Each candidate runs in its own isolated checkout/scratch directory without contaminating the others.
- [x] **Automated grading:** Reviewer agent evaluates candidates and returns machine-readable JSON with clear exit codes (0 for PASS, 1 for FAIL).
- [x] **Executed twice:** Verified deterministic, identical results across two consecutive runs.
- [x] **Proved session isolation:** Confirmed that a fresh shell/session starts with clean slate memory.
- [x] **Named loop components:** Documented the two required loop elements: **Heartbeat** and **Progress File**.
