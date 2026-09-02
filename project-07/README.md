# Project 07: Loop Observability & Cost Analysis

**Difficulty:** Medium  
**Concepts:** Observability, Concept 13 (cost), Concept 14

## Overview

This project builds on Project 3's TODO-scanning loop by adding observability and cost tracking. The goal is to understand what a loop costs to run, ensure it fails visibly when something goes wrong, and be able to diagnose failures from the artifacts it leaves behind—without replaying the full run.

## What Was Done

### 1. Loop Setup
- Created `progress.md` as the persistent spine of the loop
- Implemented a TODO/FIXME/XXX/HACK scanner that searches the repository
- Each run appends a dated entry to `progress.md` with scan results
- Uses the same Markdown format as Project 3 for consistency

### 2. Cost Measurement (Concept 13)
Measured a single beat of the loop:

- **Input tokens per run:** ~150-200 tokens
  - Reading `progress.md` (~100-150 tokens)
  - System prompt and grep results (~50-100 tokens)
  
- **Output tokens per run:** ~100-150 tokens
  - Formatted scan results and file edits

- **Total per run:** ~250-350 tokens combined

**Monthly cost calculation at 10-minute cadence:**
- Runs per day: 144 (24 hours × 6 runs/hour)
- Runs per month: ~4,320
- Tokens per month: 4,320 × 300 (avg) = **~1,296,000 tokens/month**

At current Claude Opus pricing (~$15/million input tokens, ~$75/million output tokens):
- Input: 0.864M × $15 = ~$13
- Output: 0.432M × $75 = ~$32
- **Total: ~$45/month** at 10-minute intervals

### 3. Sabotage & Failure Handling
Introduced a deliberate failure by attempting to read `notes-that-dont-exist.md` before each scan.

**Initial behavior:** Failed silently—the missing file was noted in tool results but not surfaced to the human.

**Fix applied:** Modified the loop prompt to explicitly check for the missing file and write a human-visible alert:
```
⚠️ NEEDS HUMAN: expected file notes-that-dont-exist.md was missing
```

This alert is written as the **first line** of each dated entry in `progress.md`, before the TODO scan results.

### 4. Observability
The loop now leaves behind two diagnostic artifacts:

1. **progress.md** - The persistent log showing:
   - Dated entries for each run
   - Human-visible alerts for failures (⚠️ NEEDS HUMAN)
   - TODO scan results or error states
   
2. **Git history** - Commits show when the loop ran and what changed

**Diagnosis capability achieved:**
- Can identify what failed (missing file)
- Can identify when it failed (date in the entry)
- Can see the failure without replaying the run
- Human is alerted immediately via the ⚠️ marker

## Success Criteria Met

✅ **Can say what failed and when from the spine alone** - `progress.md` shows the missing file alert with timestamp  
✅ **Loop leaves a clear "needs a human" note** - ⚠️ marker visible in progress.md  
✅ **Know the loop's monthly cost** - ~$45/month at 10-minute cadence, ~1.3M tokens/month

## Key Learnings

- **Silent failures are dangerous** - Loops that run unattended must surface errors to humans
- **Cost scales with cadence** - A 10-minute loop is 144× more expensive than daily
- **The spine is everything** - When debugging overnight failures, you only have what was written down
- **Fail visibly or don't fail at all** - Better to over-communicate errors than miss them

## Repository Structure

```
project-07/
├── README.md          # This file
└── progress.md        # Loop execution log with dated entries
```

## Next Steps

To run this loop on a schedule, use:
```bash
/loop 10m "Read notes-that-dont-exist.md. If it does not exist, do NOT skip past it silently — write '⚠️ NEEDS HUMAN: expected file notes-that-dont-exist.md was missing' as the first line of today's entry in progress.md, before anything else. Then scan this repo for TODO comments as usual and append that too."
```

Or adjust the cadence based on cost tolerance and monitoring needs.
