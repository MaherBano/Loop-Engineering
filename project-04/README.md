# Project-04: Maker-Checker Loop with Worktree

**Difficulty:** Medium to Hard  
**Concepts Used:** Worktree (Concept 8), Skill (Concept 9), Maker-Checker (Concept 11)

## Overview

This project implements a maker-checker workflow where:
1. An implementer fixes a bug in an isolated worktree
2. A reviewer agent evaluates the fix and returns PASS or FAIL
3. A PR is created only when the reviewer approves (PASS)
4. Bad fixes are rejected with detailed reasoning (FAIL)

## The Bug

The `subtract_numbers(a, b)` function in `math_utils.py` incorrectly returns `b - a` instead of `a - b`.

```python
def subtract_numbers(a, b):
    """Subtract b from a."""
    return b - a  # BUG: Should be a - b
```

## Project Components

### 1. Fix Workflow Skill (`.claude/skills/fix-math-bug.md`)

A skill that defines the implementer's workflow:
- Creates an isolated worktree using `EnterWorktree`
- Applies the fix to `math_utils.py`
- Commits the change
- Does NOT push or create PR (reviewer handles that)

### 2. Reviewer Agent (`reviewer.py`)

A strict Python script that reviews the fix with multiple criteria:

**Passing criteria:**
- ✓ Function returns `a - b` (correct logic)
- ✓ Function signature unchanged
- ✓ Docstring accurate
- ✓ No unrelated changes to `add_numbers`

**Failure conditions:**
- Still returns `b - a` (bug not fixed)
- Recursive calls (infinite recursion)
- Modified function signature
- Broken `add_numbers` function
- Missing return statement

Returns JSON with `verdict` (PASS/FAIL) and detailed `reasons`.

## Demonstration Results

### ✅ Scenario 1: Good Fix → PASS → PR Created

**Worktree:** `fix-subtract-bug-good`  
**Branch:** `worktree-fix-subtract-bug-good`  
**Fix Applied:** Changed `return b - a` to `return a - b`

**Reviewer Response:**
```json
{
  "verdict": "PASS",
  "reasons": [
    "✓ Correct: subtract_numbers returns a - b",
    "✓ Docstring is accurate",
    "✓ add_numbers function unchanged"
  ]
}
```

**Outcome:** ✅ PR created → https://github.com/MaherBano/Loop-Engineering/pull/4

---

### ❌ Scenario 2: Bad Fix → FAIL → No PR

**Worktree:** `fix-subtract-bug-bad`  
**Branch:** `worktree-fix-subtract-bug-bad`  
**Fix Applied:** Changed to `return subtract_numbers(b, a)` (recursive call)

**Reviewer Response:**
```json
{
  "verdict": "FAIL",
  "reasons": [
    "CRITICAL: Recursive call detected - will cause infinite recursion: return subtract_numbers(b, a)",
    "The fix must directly return a - b, not recursively call itself"
  ]
}
```

**Outcome:** ❌ No PR created. Fix rejected with clear reasoning.

## How to Run

### Run the full workflow:

1. **Apply a fix in a worktree:**
   ```bash
   # Enter worktree
   # Make changes to math_utils.py
   # Commit changes
   ```

2. **Review the fix:**
   ```bash
   python reviewer.py path/to/math_utils.py
   ```

3. **If PASS (exit code 0):** Push and create PR
   ```bash
   git push -u origin <branch-name>
   gh pr create --title "fix: ..." --body "..."
   ```

4. **If FAIL (exit code 1):** Read reasons, iterate on fix

## Key Learnings

1. **Worktree isolation**: Each fix attempt gets its own checkout, preventing interference
2. **Automated gating**: The reviewer acts as a quality gate - only good fixes proceed to PR
3. **Clear feedback**: Failed reviews provide specific reasons, not just "rejected"
4. **Exit codes matter**: Scripts use exit codes (0=PASS, 1=FAIL) for automation

## Success Criteria ✅

Both conditions met:

1. ✅ **Good fix gets PASS and PR**: The correct fix (`return a - b`) passed review and PR #4 was created
2. ✅ **Bad fix gets FAIL with reasons**: The recursive fix was rejected with detailed explanation about infinite recursion

The checker is properly tuned - not too soft (catches bad fixes) and not too strict (allows good fixes).
