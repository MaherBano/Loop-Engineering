# Project 08: Full Autonomous Loop - Architecture Plan

## Chosen Recurring Chore
**Dependency & Documentation Audit** for the loop-engineering repository

This loop will:
- Scan all Python files for imports
- Check if dependencies are documented in requirements.txt files
- Verify README files exist and mention the main modules
- Flag missing or stale documentation
- Create PRs with fixes when possible

## The Six Components

### 1. Heartbeat (Scheduled Execution)
- **Schedule:** Every 6 hours (4x daily) using CronCreate
- **Cron:** `37 */6 * * *` (offset from :00 to avoid API congestion)
- **Duration:** 7 days (auto-expires as designed)
- **Budget:** ~$2-3/day, ~$60/month maximum

### 2. Worktree (Isolated Workspace)
- Each run creates a fresh worktree via EnterWorktree
- Branch naming: `audit/YYYY-MM-DD-HHMM`
- Prevents contamination between runs
- Auto-cleanup on completion

### 3. Skill (Packaged Instructions)
- File: `.claude/skills/dependency-audit.md`
- Encapsulates: scan logic, fix patterns, reporting format
- Invocable via `/dependency-audit` or Skill tool
- Can be improved without changing the heartbeat

### 4. Maker-Checker (Review Before Merge)
- All changes go through PR review
- Loop creates PR with findings and proposed fixes
- PR description includes:
  - What was found
  - What was changed
  - Confidence level (auto-merge safe vs needs review)
- Uses GitHub connector to create PRs via `gh` CLI

### 5. Connector (External Integration)
- **Primary:** GitHub (PR creation, status checks)
- **Tool:** `gh pr create` for PR submission
- **Notifications:** PR notifications alert humans when review needed
- **Future:** Could add Slack notifications via webhook

### 6. Spine (Persistent Log)
- File: `audit-log.md` in project-08 directory
- Each run appends a dated entry with:
  - Timestamp
  - Findings summary
  - Actions taken (PR created, no changes, etc.)
  - Errors or blockers
  - Token usage and cost
- Survives worktree cleanup
- Enables diagnosis without replaying runs

## Budget Guards

### Token Limits
- **Per-run cap:** 50,000 tokens (~$5 worst case)
- **Daily cap:** 200,000 tokens (~$20)
- **Monthly cap:** 4,000,000 tokens (~$400)

### Implementation
- Track token usage in each run
- Write token count to spine
- Abort if approaching limits
- Alert human via spine if budget exceeded

### Cost Estimation
- Typical run: 5,000-15,000 tokens (~$0.50-$1.50)
- 4 runs/day: ~$2-6/day
- 7 days: ~$14-42 total
- Well within budget constraints

## Failure Modes & Observability

### What Can Fail
1. **Git operations** - worktree creation, branch conflicts
2. **Scan errors** - malformed Python files
3. **PR creation** - GitHub auth, network issues
4. **Token budget** - exceeding limits

### How We'll Know
- Every failure writes to spine with ⚠️ marker
- Failed runs still commit spine changes
- PR creation failures logged visibly
- Token usage tracked per run

### Recovery
- Heartbeat retries next cycle (6 hours later)
- Worktree cleanup on failure (no state pollution)
- Spine preserves error context for debugging

## Success Criteria

Done when:
1. ✅ Loop runs unattended for 7 days
2. ✅ Creates PRs when it finds issues
3. ✅ I trust the output because I read it, not because I stopped reading
4. ✅ My understanding of the project keeps up with changes
5. ✅ Budget stays within limits
6. ✅ Failures are diagnosed from spine alone

## Implementation Order

1. **Design** (this document)
2. **Skill** - write the audit logic
3. **Spine** - create audit-log.md structure
4. **Budget guards** - token tracking
5. **Manual test** - run skill in worktree, verify PR creation
6. **Heartbeat** - schedule via CronCreate
7. **Monitor** - let it run for 7 days

## Next Steps

Start with the skill definition - this is the core logic that everything else orchestrates.
