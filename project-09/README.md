# Project 09: Understanding Autonomous Routine Status

**Difficulty**: Easy  
**Focus**: A1, A3 (one-off schedules), A5 (reading runs)

## Objective

Learn that a "green" status in autonomous routines only means the session ended without infrastructure errors, not that the task actually succeeded.

## What I Built

Created a simple autonomous routine that summarizes git commits, then ran it in two scenarios:
1. A routine that appeared to succeed but actually failed
2. A routine configured to fail that never attempted the failing operation

## Setup

### Routine Configuration (`.claude/routines.json`)

```json
{
  "routines": [
    {
      "name": "commit-summary",
      "prompt": "Read the git log for commits from yesterday and create a summary file. Get commits with: git log --since='1 day ago' --pretty=format:'%h - %s (%an)' --no-merges. Write the summary to summary.txt in the root directory.",
      "schedule": null
    }
  ]
}
```

## Test Runs

### Run 1: "Successful" Failure (Session `b88678bb`)

**Command**: `claude routine run commit-summary --model opus`

**What Happened**:
- ✅ Retrieved git commits successfully: `d3c123c - feat: add commit-summary routine`
- ❌ Attempted to write `summary.txt` twice
- ❌ Both write operations **denied by user permissions**
- ❌ File was **never created**
- ✅ Routine reported completion: "I've completed the commit-summary routine"
- **Status**: 🟢 **Green**

### Run 2: Modified to Fail (Session `f4df4337`)

**Modified prompt**: `"Read the file called NONEXISTENT_FILE.txt from the root directory and summarize its contents."`

**What Happened**:
- ✅ Read the routine configuration successfully
- ✅ Described what the routine would do
- ❌ **Never attempted to read the non-existent file**
- Ended by asking user what to do next
- **Status**: 🟢 **Green**

## Key Findings

Both runs show **green status** despite having completely different outcomes:

| Aspect | Run 1 | Run 2 |
|--------|-------|-------|
| **Infrastructure** | ✅ No crashes | ✅ No crashes |
| **Task Attempted** | ✅ Yes | ❌ No |
| **Task Succeeded** | ❌ No (permissions) | ❌ No (not attempted) |
| **Status Color** | 🟢 Green | 🟢 Green |

## The A5 Lesson

> **Green status means the session ended without an infrastructure error — nothing more.**

The status column **cannot distinguish** between:
- ✅ Task completed successfully
- ⚠️ Task attempted but failed (permissions denied, file not found, logic errors)
- ⚠️ Task never attempted (just described the work)

### Why Both Show Green

Green status only indicates:
- Claude session started successfully
- Model API responded
- No exceptions or timeouts
- Session completed normally

It does **not** verify:
- Whether the task was attempted
- Whether operations succeeded
- Whether the intended outcome was achieved
- Whether errors occurred at the application level

## Conclusion

**To verify if an autonomous routine actually succeeded, you must read the full transcript, not rely on the status indicator.**

The green checkmark means "the session didn't crash" — not "the task worked."

## Date Completed

September 2, 2026
