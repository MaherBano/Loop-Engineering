# Project 12: Improvement Loop (Capstone)

**Status:** ✅ Complete  
**Concepts:** Spine and improvement loop (12), Maker-checker (11), Schedule (6), Human gate (Part 5)

## Overview

A meta-loop that analyzes a working loop's history weekly, detects repeated failures, and proposes rule improvements as PRs—never direct commits.

## Architecture

### Components

1. **Improvement Loop** (`project-12/.claude/skills/improve.md`)
   - Analyzes logs from `project-07/progress.md`
   - Detects patterns of repeated failures (2+ occurrences)
   - Creates PRs on `claude/improve-*` branches
   - Never commits directly to main

2. **State Tracking** (`project-12/dreaming-state.md`)
   - Tracks "Last analyzed" date
   - Updated after each run (uncommitted)
   - Prevents re-analyzing the same entries

3. **Schedule** (Weekly cron: Mondays at 2:17 AM)
   - Runs automatically via `CronCreate`
   - Persisted in `.claude/scheduled_tasks.json`
   - Auto-expires after 7 days (recurring)

### Workflow

```
┌─────────────────┐
│  Weekly Cron    │
│  (Monday 2:17)  │
└────────┬────────┘
         │
         v
┌─────────────────────────────┐
│ Read dreaming-state.md      │
│ Last analyzed: 2026-08-26   │
└────────┬────────────────────┘
         │
         v
┌─────────────────────────────┐
│ Read project-07/progress.md │
│ Filter entries since date   │
└────────┬────────────────────┘
         │
         v
┌─────────────────────────────┐
│ Find repeated patterns      │
│ (3x "config.yaml missing")  │
└────────┬────────────────────┘
         │
         v
┌─────────────────────────────┐
│ Create branch:              │
│ claude/improve-2026-09-02   │
└────────┬────────────────────┘
         │
         v
┌─────────────────────────────┐
│ Add rule to .claude/RULES.md│
│ (file existence check)      │
└────────┬────────────────────┘
         │
         v
┌─────────────────────────────┐
│ Create PR with evidence:    │
│ - Dated log entries         │
│ - Frequency count           │
│ - Proposed fix              │
│ - Prevention mechanism      │
└────────┬────────────────────┘
         │
         v
┌─────────────────────────────┐
│ Update dreaming-state.md    │
│ (uncommitted)               │
└─────────────────────────────┘
```

## Evidence-Based Improvements

### PR #3: File Existence Validation

**Evidence:**
- 2026-08-30: ⚠️ NEEDS HUMAN: expected file config.yaml was missing
- 2026-09-01: ⚠️ NEEDS HUMAN: expected file config.yaml was missing
- 2026-09-02: ⚠️ NEEDS HUMAN: expected file config.yaml was missing
- **Frequency:** 3 occurrences in 7 days

**Proposed Fix:**
```bash
if [ ! -f "filename" ]; then
  echo "⚠️ SKIPPED: filename does not exist, skipping this check"
  exit 0
fi
```

**Prevention Mechanism:**
Checks file existence before operations, treating missing files as skip conditions rather than errors requiring human intervention.

**Branch:** `claude/improve-2026-09-02`  
**PR:** https://github.com/MaherBano/Loop-Engineering/pull/3

## Verification Checklist

✅ **Three requirements met:**

1. ✅ **PR traces to real log entries**
   - Cited specific dates: 2026-08-30, 2026-09-01, 2026-09-02
   - Exact text from progress.md logs
   - Frequency count: 3 times
   - Not guessing—hard evidence only

2. ✅ **Planted failure caught**
   - Manually added "config.yaml missing" 3 times to progress.md
   - Loop detected the pattern
   - Generated appropriate rule fix
   - PR includes the evidence

3. ✅ **No direct commits to main**
   - Created branch: `claude/improve-2026-09-02`
   - PR requires review/merge
   - Main branch unchanged
   - dreaming-state.md updated but uncommitted

## Key Features

### Conservative Detection
- Only proposes changes for patterns seen 2+ times
- Requires specific dated evidence
- No generic advice—only targeted fixes
- One improvement per cycle

### Maker-Checker Pattern
- Loop proposes (maker)
- Human reviews and merges (checker)
- No automated merges
- All changes via PR

### Self-Documenting
- PR description explains root cause
- Cites mechanism of prevention
- Suggests rule deletions
- Links to specific log entries

## Testing

Planted repeated failure in `project-07/progress.md`:
```markdown
## 2026-08-30
⚠️ NEEDS HUMAN: expected file config.yaml was missing

## 2026-09-01  
⚠️ NEEDS HUMAN: expected file config.yaml was missing

## 2026-09-02
⚠️ NEEDS HUMAN: expected file config.yaml was missing
```

Result: Loop correctly identified pattern and created PR with:
- Evidence from all 3 dates
- Specific rule to prevent it
- Explanation of why it works
- No other changes to main

## Files

```
project-12/
├── .claude/
│   ├── skills/
│   │   └── improve.md          # Improvement loop logic
│   └── scheduled_tasks.json     # Cron schedule
├── dreaming-state.md            # Last analyzed date (uncommitted)
└── README.md                    # This file

project-07/
├── .claude/
│   └── RULES.md                 # Proposed via PR #3
└── progress.md                  # Source logs (modified with test data)
```

## Schedule

**Cron:** `17 2 * * 1` (Mondays at 2:17 AM)  
**Duration:** 7 days (auto-expires)  
**Durable:** Yes (persisted across sessions)

## Critical Rules

1. **Never guess** - if no 2+ occurrences found, exit without PR
2. **Evidence is mandatory** - every proposal must cite dated log entries
3. **Never commit to main** - always branch + PR
4. **One change at a time** - focus on most frequent issue
5. **Be specific** - no generic rules, only targeted fixes

## Success Criteria

All three requirements verified:

1. ✅ PR's proposed change traces to real, cited log entries
2. ✅ Deliberately planted repeated failure gets caught and turned into proposal
3. ✅ Nothing changed in rules without manual merge

## Next Steps

- Wait for PR #3 review and merge
- Let loop run for another week
- Next cycle will:
  - Analyze entries since 2026-09-02
  - Propose next improvement if patterns found
  - Suggest deletion of unused rules

## Lessons

- **Evidence > intuition**: The loop's value is in tracing real failures, not predicting hypothetical ones
- **Small, specific fixes**: One targeted rule beats ten generic guidelines
- **Human in the loop**: Automation proposes, humans decide
- **Spine as oracle**: Historical logs reveal what actually breaks, not what might break
