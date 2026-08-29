# Project 08: Full Autonomous Loop (Capstone)

**Difficulty:** Capstone  
**Uses:** All six parts of loop engineering

## Overview

This is a complete autonomous loop that runs unattended for 7 days, auditing Python dependencies and documentation across the loop-engineering repository. It demonstrates all six components of production loop engineering.

## The Recurring Chore

**Dependency & Documentation Audit**
- Scans all Python files for import statements
- Checks if requirements.txt files exist and are up to date
- Verifies documentation (README files) exist
- Flags missing or stale documentation
- Creates PRs with fixes when safe to do so

## The Six Components

### 1. ⏰ Heartbeat (Scheduled Execution)
- **Schedule:** Every 6 hours using CronCreate
- **Cron:** `37 */6 * * *` (offset from :00 to reduce API load)
- **Duration:** 7 days (auto-expires as designed)
- **Durable:** Yes - survives session restarts via `.claude/scheduled_tasks.json`

### 2. 🌳 Worktree (Isolated Workspace)
- Each run creates a fresh worktree via `EnterWorktree`
- Branch naming: `audit-YYYY-MM-DD-HHMM`
- Prevents contamination between runs
- Kept on disk after PR creation for reference
- Removed if no changes made

### 3. 📋 Skill (Packaged Instructions)
- **Primary:** `.claude/skills/dependency-audit.md`
- **Wrapper:** `.claude/skills/audit-with-budget.md` (adds budget guards)
- Encapsulates: scan logic, fix patterns, reporting format
- Can be improved without changing the heartbeat

### 4. ✅ Maker-Checker (Review Before Merge)
- All changes go through PR review
- Loop creates PR with:
  - Summary of findings
  - What was changed and why
  - Confidence level (safe to auto-merge vs needs review)
- PR link added to spine for tracking

### 5. 🔗 Connector (External Integration)
- **GitHub Integration:** PR creation via `gh pr create`
- **Notifications:** PR notifications alert humans when review needed
- **Status tracking:** PR URLs logged in spine
- **Future:** Could add Slack webhooks for alerts

### 6. 📖 Spine (Persistent Log)
- **File:** `audit-log.md` in project-08 directory
- **Lives in main repo** - not affected by worktree cleanup
- Each run appends a dated entry with:
  - Timestamp
  - Findings summary
  - Actions taken (PR created, no changes, etc.)
  - Errors or blockers (⚠️ markers)
  - Token usage estimate
  - PR links for traceability

## Budget Guards

### Token Limits
- **Per-run cap:** 50,000 tokens (~$5 worst case)
- **Emergency stop:** 45,000 tokens (leave room for cleanup)
- **Typical run:** 5,000-15,000 tokens (~$0.50-$1.50)

### Cost Estimates
- **Per run:** ~$0.50-$1.50
- **4 runs/day:** ~$2-6/day
- **7 days:** ~$14-42 total
- **Monthly (if continued):** ~$60-180

### Enforcement
The skill self-limits by:
- Stopping after scanning 50 Python files
- Stopping after finding 20 issues
- Stopping after fixing 10 files
- Logging budget exceeded to spine with ⚠️

## Observability

### What Gets Logged
1. **Every run** - success or failure
2. **All findings** - what was discovered
3. **All actions** - what was changed
4. **All errors** - with ⚠️ markers
5. **Token usage** - per-run estimates
6. **PR links** - for traceability

### Failure Modes
The loop can fail due to:
- Git operations (worktree creation, conflicts)
- Scan errors (malformed Python files)
- PR creation (GitHub auth, network issues)
- Token budget exceeded

All failures write to spine with ⚠️ marker before exiting.

### Diagnosis Without Replay
From `audit-log.md` alone, you can determine:
- What failed (error message)
- When it failed (timestamp)
- What it was trying to do (context)
- What it had accomplished so far (partial results)

## Manual Test Run

**Date:** 2026-08-29 15:00

### Results
✅ **Worktree isolation** - Changes isolated in `audit-test-2026-08-29`  
✅ **Skill execution** - Found 4 missing requirements.txt files  
✅ **Maker-checker** - Created PR #1 with proper context  
✅ **Connector** - GitHub integration worked via gh CLI  
✅ **Spine logging** - Entry written to audit-log.md  
✅ **Budget tracking** - ~5,800 tokens used (well within limits)

### First PR
- **PR #1:** https://github.com/MaherBano/Loop-Engineering/pull/1
- **Changes:** Added requirements.txt to 4 projects
- **Confidence:** HIGH (safe to merge)

## Running It

### Check Schedule Status
```bash
/cron list
```

### Cancel Schedule
```bash
/cron delete b0845be5
```

### Manual Run
```bash
/dependency-audit
```

### Check Logs
```bash
cat project-08/audit-log.md
```

## Success Criteria

✅ **Runs unattended for 7 days** - Scheduled via CronCreate  
✅ **Creates PRs when issues found** - PR #1 created in test  
✅ **Trust output because I read it** - Full context in PR and spine  
⏳ **Understanding keeps up with changes** - To be verified over 7 days  
✅ **Budget stays within limits** - Guards implemented and tested  
✅ **Failures diagnosed from spine** - ⚠️ markers and error logging

## Repository Structure

```
project-08/
├── README.md                              # This file
├── PLAN.md                                # Architecture design document
├── audit-log.md                           # The spine (execution log)
└── .claude/
    └── skills/
        ├── dependency-audit.md            # Core audit logic
        └── audit-with-budget.md           # Budget-enforced wrapper
```

## Next Steps

### Days 1-7: Observe
- Let it run for 7 days unattended
- Check spine daily: `cat project-08/audit-log.md`
- Review PRs when created
- Note any failures or budget issues

### After 7 Days: Retrospective
Answer Concept 15 honestly:
- Did my understanding keep up with changes?
- Did I trust the output because I read it?
- Or did I stop reading?

If understanding lagged behind:
- Slow the loop down (every 12h or daily)
- Add more context to PR descriptions
- Improve spine logging detail

### When It Fails (It Will)
Follow "When an unattended loop fails":
1. Read the spine to understand what failed
2. Check if it's transient (network) or systemic (logic bug)
3. Fix the skill or adjust budget
4. Resume via CronCreate (it auto-resumes from schedule)

## Key Learnings

### From the Manual Test
- **Worktree isolation works** - Clean separation between runs
- **Spine must live in main repo** - Not in worktree
- **GitHub labels need pre-creation** - Can't add non-existent labels
- **Budget estimation is hard** - Need to track actual usage over time

### Design Principles Applied
1. **Fail visibly** - ⚠️ markers in spine
2. **Self-limiting** - Budget guards prevent runaway costs
3. **Traceable** - PR links connect spine to GitHub
4. **Conservative** - Only fix safe things, flag rest for human
5. **Autonomous but supervised** - Runs unattended but PRs need approval

## Cost Analysis

Based on the manual test run:

| Metric | Value |
|--------|-------|
| Tokens per run | ~5,800 |
| Cost per run | ~$0.60 |
| Runs per day | 4 |
| Daily cost | ~$2.40 |
| Weekly cost | ~$16.80 |
| Monthly cost (extrapolated) | ~$72 |

At current Claude Opus pricing (~$15/M input, ~$75/M output).

This is within the planned budget of ~$60-180/month for a 6-hour cadence.

## Monitoring Commands

```bash
# Check if loop is running
/cron list

# View the spine
cat project-08/audit-log.md

# Check recent PRs
gh pr list

# View a specific worktree
cd .claude/worktrees/audit-YYYY-MM-DD-HHMM

# Clean up old worktrees (after merging PRs)
git worktree prune
```

## Future Enhancements

- Add Slack notifications for failures
- Track actual token usage (not just estimates)
- Auto-merge PRs with HIGH confidence
- Expand to check for security vulnerabilities
- Add linting and formatting checks
- Generate README stubs (not full rewrites)

---

🤖 **Status:** LIVE - Running every 6 hours until 2026-09-05  
📊 **Next run:** Check `/cron list` for countdown  
📝 **Spine:** `project-08/audit-log.md`
