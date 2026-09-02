# Project 11: Human Gate with API Triggers

**Status**: Setup Complete - Ready for Execution  
**Date**: September 2, 2026

## What Was Built

This project implements a two-routine approval workflow demonstrating the human gate pattern:

1. **Routine A (draft-changelog)**: Creates a draft changelog from recent git commits on a new branch
2. **Routine B (approve-changelog)**: Merges the approved draft when triggered via API

## Files Created

- `.claude/routines.json` - Routine definitions (template)
- `.claude/settings.json` - Security configuration with state file and restricted permissions
- `.gitignore` - Excludes bearer tokens and state files
- `SETUP-GUIDE.md` - Detailed step-by-step instructions
- `A6-CHECKLIST.md` - Comprehensive verification checklist
- `quick-start.sh` - Interactive script for executing the workflow
- `README.md` - This file

## Quick Start

You have two options to execute this project:

### Option 1: Use the Quick Start Script (Recommended)

```bash
bash quick-start.sh
```

This interactive script will guide you through:
1. Creating both routines
2. Running Routine A
3. Reviewing the draft
4. Firing Routine B via API
5. Verifying the results

### Option 2: Manual Execution

Follow the detailed instructions in `SETUP-GUIDE.md`.

## Key Requirements (from Project Spec)

✅ **Routine A**: Runs on one-off schedule, drafts something reviewable  
✅ **Routine B**: Has API trigger, performs follow-up action  
✅ **Security**: Bearer token must be stored immediately (shown once)  
✅ **Human Gate**: You must manually review A's draft before firing B  
✅ **A6 Checklist**: Verify connectors pruned, unrestricted pushes off, state file chosen

## How It Works

1. **Draft Phase**: Routine A analyzes git history and creates a changelog on a feature branch
2. **Review Phase**: You manually review the draft changelog
3. **Approval Phase**: You fire Routine B via curl with the bearer token
4. **Merge Phase**: Routine B merges the approved changelog into main

## Security Configuration

The `.claude/settings.json` file ensures:
- No unrestricted git push permissions
- Only specific git commands are allowed
- No external connectors configured
- State file properly configured for audit trail

## Verification

After execution, work through `A6-CHECKLIST.md` to verify:
- B ran only because you fired it (check run history)
- B's transcript shows the action actually happened (open the session)
- All A6 checklist items pass

## Important Notes

- **Bearer tokens are shown only once** - save immediately to `bearer-token.txt`
- **Green status ≠ success** - always check the transcript to verify actual execution
- **API triggers are per-routine** - each routine gets its own endpoint and token
- Routines run on Anthropic cloud infrastructure, not locally

## Documentation References

- Routines: https://code.claude.com/docs/en/routines.md
- Web UI: https://claude.ai/code/routines

## Next Steps

1. Run `bash quick-start.sh` or follow `SETUP-GUIDE.md`
2. Complete the workflow end-to-end
3. Verify all checks in `A6-CHECKLIST.md`
4. Document your findings and any issues encountered

---

**Project Difficulty**: Medium to Hard  
**Concepts Demonstrated**: API triggers (A3), Human gates (A4), Verification checklist (A6)
