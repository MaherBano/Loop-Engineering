# Project 01 - In-Session Loop Monitoring

**Difficulty:** Easy  
**Concept:** Concept 4 (In-session loop)  
**Completed:** August 20, 2026

## Overview

This project demonstrates an in-session loop that monitors a long-running background task and notifies when it completes. The goal was to set up automated checking so you don't need to sit watching the terminal waiting for a task to finish.

## Requirements

Build a system that:
1. Starts a long-running task in the repo
2. Sets up an in-session loop that checks every minute whether the task has finished
3. Notifies the moment the task completes
4. Can be stopped cleanly
5. Eliminates the need to watch the terminal manually

## Implementation

### Files

- **`long-task.sh`** - A bash script that simulates a long-running task
  - Sleeps for 3 minutes (180 seconds)
  - Writes "done" to `result.txt` when complete
  
- **`result.txt`** - Output file that indicates task completion
  - Contains "done" when the task finishes

### How It Works

1. **Long Task**: The `long-task.sh` script runs in the background, sleeping for 3 minutes before writing its completion status
2. **Loop Monitoring**: An in-session loop (using `/loop` with 1-minute intervals) checks for the existence and content of `result.txt`
3. **Notification**: When the loop detects "done" in the result file, it notifies you once
4. **Clean Stop**: The loop can be stopped cleanly without manual terminal watching

### Usage

1. Start the long-running task:
   ```bash
   ./long-task.sh &
   ```

2. Set up the monitoring loop (in Claude Code):
   ```
   /loop 1m check if result.txt exists and contains "done"
   ```

3. The loop will check every minute and notify you when the task completes

4. Stop the loop when done or if needed before completion

## Key Concepts Demonstrated

- **Background task execution** - Running shell scripts asynchronously
- **Polling pattern** - Checking file system state at regular intervals
- **In-session automation** - Using Claude's `/loop` command for periodic checks
- **Clean termination** - Stopping monitoring loops without manual intervention

## Success Criteria Met

✅ Loop notices when the task finished  
✅ Notification happens exactly once  
✅ Loop can be stopped cleanly  
✅ No need to watch the terminal manually

## Notes

- The 3-minute sleep duration is arbitrary and can be adjusted for different use cases
- The 1-minute check interval balances responsiveness with resource usage
- This pattern works for any task that signals completion via file system changes
