# Project 11: Human Gate with API Triggers

## Overview
This project implements a two-routine workflow with a human approval gate:
- **Routine A (draft-changelog)**: Runs on-demand, creates a draft changelog on a branch
- **Routine B (approve-changelog)**: Has an API trigger, merges the approved draft when fired via curl

## Setup Steps

### Step 1: Create Routine A (draft-changelog)

Run this command in your terminal:

```bash
claude "Create a routine named 'draft-changelog' with this prompt: Read the git log for commits from the last 7 days using: git log --since='7 days ago' --pretty=format:'%h - %s (%an, %ar)' --no-merges. Create a draft changelog on a new branch called 'changelog-draft' with these changes formatted nicely in a CHANGELOG.md file. Include sections for Features, Fixes, and Other. At the end of your response, output the curl command needed to trigger the 'approve-changelog' routine."
```

Or use the web UI at https://claude.ai/code/routines and create it there.

### Step 2: Create Routine B (approve-changelog) with API Trigger

1. Go to https://claude.ai/code/routines
2. Click "Create routine"
3. Set name: `approve-changelog`
4. Set prompt: `Merge the 'changelog-draft' branch into main. First verify the branch exists and has a CHANGELOG.md file, then perform the merge with a commit message 'docs: merge approved changelog'. Push the changes to remote.`
5. Under "Select a trigger" → Click "Add another trigger" → Choose "API"
6. Click "Generate token" 
7. **CRITICAL: Copy the bearer token immediately** - it's shown only once!
8. Save the token to: `bearer-token.txt` (gitignored)

### Step 3: Configure Settings

The `.claude/settings.json` file is already configured with:
- State file location: `.claude/routine-state.json`
- Appropriate git command permissions
- No unrestricted push permissions (safety)

### Step 4: Run Routine A (One-off Schedule)

```bash
# Option 1: Via web UI
# Go to https://claude.ai/code/routines, find "draft-changelog", click "Run now"

# Option 2: Via CLI (in an interactive session)
claude
# Then type: /schedule run draft-changelog
```

### Step 5: Review the Draft

1. Check the run status at https://claude.ai/code/routines
2. Open the run session to see the transcript
3. Verify the changelog-draft branch was created
4. Review CHANGELOG.md content

```bash
git fetch
git checkout changelog-draft
cat CHANGELOG.md
```

### Step 6: Approve via API Trigger (Fire Routine B)

Once you've reviewed and approve the draft, fire Routine B with curl:

```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/trig_<YOUR_TRIGGER_ID>/fire \
  -H "Authorization: Bearer <YOUR_BEARER_TOKEN>" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"text": "Approved for merge"}'
```

Replace:
- `<YOUR_TRIGGER_ID>`: The trigger ID from the routine's API trigger configuration
- `<YOUR_BEARER_TOKEN>`: The token you saved in Step 2

### Step 7: Verify the Merge

1. Check Routine B's run status and transcript
2. Verify the merge happened:

```bash
git checkout main
git pull
cat CHANGELOG.md
git log --oneline -5
```

## A6 Checklist

After both routines complete, verify:

- ✅ **Connectors pruned**: No unnecessary external connectors configured
- ✅ **Unrestricted pushes off**: Settings don't allow unrestricted git push (check `.claude/settings.json`)
- ✅ **State file chosen**: State file is configured at `.claude/routine-state.json`
- ✅ **Routine A ran only when manually triggered**: Check run history shows one-off execution
- ✅ **Routine B ran only when API fired**: Check run history shows it fired from curl, not automatically
- ✅ **Routine B's transcript shows actual action**: Open the run and verify the merge actually happened

## Success Criteria

✅ Routine B ran **only** because you fired the API trigger  
✅ Routine B's transcript shows the merge **actually happened**  
✅ A6 checklist passes all verification points

## Files in This Project

- `.claude/routines.json` - Routine configurations (for reference, actual routines created via CLI/web)
- `.claude/settings.json` - Project settings with state file and permissions
- `.gitignore` - Excludes bearer token and state files
- `SETUP-GUIDE.md` - This guide
- `bearer-token.txt` - (You create this) Store the API bearer token here
