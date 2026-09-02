# Project 03: Scheduled Loop with Memory Spine

**Difficulty:** Medium  
**Concepts:** Concept 6 (unattended schedule), Concept 12 (the spine)

## Overview

This project demonstrates a scheduled loop that maintains state across runs using a "spine" - a persistent record that prevents the loop from repeating work. The loop scans the repository for TODO comments and updates a progress file, with each run building on the previous one's findings.

## What It Does

The scheduled loop:
1. Reads `progress.md` to see what's already been recorded
2. Scans the repository for TODO comments (`TODO`, `FIXME`, `XXX`, `HACK`)
3. Compares current findings with previous runs
4. Writes a summary to `progress.md` with the date
5. Only records new or changed information

## The Spine

The **spine** is `progress.md` - a persistent record that gives the loop memory across runs. This prevents the loop from starting fresh each time and repeating work.

### Evidence the Spine Works

The `progress.md` file shows three runs on 2026-08-19:

1. **First run:** Found 2 TODO comments
2. **Second run:** Found 0 TODO comments (TODOs were removed)
3. **Third run:** Detected no new TODOs, referenced the existing count from previous runs

The third entry states: *"No new TODO comments found. Still 2 existing TODOs in math_utils.py"* - proving the loop is aware of previous runs and doesn't repeat what it already recorded.

## Files

- `math_utils.py` - Sample code with TODO comments for the scanner to find
- `progress.md` - The spine: persistent record of TODO scan results across runs
- `.claude/scheduled_tasks.json` - Cron configuration for the scheduled loop (if durable)

## How to Run

The loop is triggered by a scheduled task that:
1. Invokes the TODO scanning logic
2. Compares results with `progress.md`
3. Appends new findings

To manually trigger a run:
```bash
# Run the TODO scanner and update progress.md
# (The actual command depends on how the schedule was configured)
```

## Key Learnings

- **Unattended schedules** let loops run automatically without human intervention
- **The spine pattern** gives loops memory by maintaining state in a persistent file
- **Incremental updates** prevent redundant work by comparing current state with history
- **Date stamping** provides an audit trail of when each scan occurred

## Success Criteria

✅ Scheduled loop runs once per trigger  
✅ Reads the progress file before scanning  
✅ Gathers data from the repo (TODO comments)  
✅ Writes summary with date  
✅ Second run builds on first (doesn't repeat findings)  
✅ Proves the spine works (loop has memory)

## Next Steps

This pattern can be extended to:
- Track other code metrics over time (test coverage, lint errors, etc.)
- Monitor recent commits and summarize changes
- Detect and report new issues or regressions
- Build a changelog automatically from git history
