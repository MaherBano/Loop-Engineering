---
name: improve
description: Analyze loop history and propose rule improvements based on repeated failures
---

# Improvement Loop Skill

You are an improvement loop that analyzes a working loop's history to propose rule changes.

## Your Task

1. **Read the state file** `../dreaming-state.md` to find the date you last analyzed logs.

2. **Read the target loop's progress.md** at `../../project-07/progress.md` and collect all log entries since your last-analyzed date.

3. **Find repeated failures or corrections**:
   - Look for error messages, warnings, or "NEEDS HUMAN" entries that appear more than once
   - Look for the same mistake corrected multiple times
   - Look for patterns that indicate a missing rule or check

4. **Draft ONE improvement as a PR**:
   - Create a new branch named `claude/improve-YYYY-MM-DD`
   - Propose the SMALLEST change to `.claude/` rules or a skill file that would prevent the most-repeated failure
   - The change must be specific, not generic advice
   - Write a PR description that includes:
     * **Evidence**: List the specific dates and entries from progress.md showing the repeated failure
     * **Frequency**: How many times it occurred
     * **Proposed fix**: The exact rule or check being added
     * **Why this prevents it**: Explain the mechanism

5. **Propose ONE deletion**:
   - In the same PR description (not as a code change), suggest one rule from `.claude/` that recent runs didn't need
   - Cite evidence: "No entry in the last N days needed this rule"

6. **Update dreaming-state.md**:
   - Set "Last analyzed" to today's date
   - DO NOT commit this - leave it as an uncommitted change

## Critical Requirements

- **Never commit directly to main** - always create a PR branch
- **Never guess** - if you find no repeated failures with 2+ occurrences, say so and exit without creating a PR
- **Evidence is mandatory** - every proposal must cite specific dated entries from progress.md
- **Be conservative** - only propose changes for patterns you've seen at least twice
- **One PR at a time** - focus on the most frequent issue

## PR Description Template

```
## Improvement Proposal

### Evidence
- 2026-08-29: [exact text from log]
- 2026-08-30: [exact text from log]
- Occurred N times total

### Root Cause
[What pattern in the loop allows this to happen]

### Proposed Fix
[The specific rule/check being added]

### Why This Prevents It
[Mechanism of prevention]

### Suggested Deletion
Rule: [name/description]
Reason: No run in the last N days needed this check
```

## Example

Good evidence:
```
- 2026-08-29: ⚠️ NEEDS HUMAN: expected file notes.md was missing
- 2026-08-31: ⚠️ NEEDS HUMAN: expected file todo.md was missing
```

Bad evidence:
```
- "Files were sometimes missing" (not specific)
- "I noticed a pattern" (not cited)
```

## Output

When you finish:
- Report the branch name created
- Show the PR description you wrote
- Confirm dreaming-state.md is updated (but not committed)
- If no repeated failures found, report "No improvements needed - no patterns repeated 2+ times"
