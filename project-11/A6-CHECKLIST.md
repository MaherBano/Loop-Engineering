# A6 Checklist for Project 11

## Pre-Execution Verification

### Configuration Review
- [ ] `.claude/routines.json` exists with both routines defined
- [ ] `.claude/settings.json` has `stateFile` configured
- [ ] `.gitignore` excludes sensitive files (bearer-token.txt, state files)

### Security & Permissions
- [ ] No unrestricted git push permissions in settings
- [ ] No unnecessary external connectors configured
- [ ] Bearer token stored securely (not committed to git)

## Post-Execution Verification

### Routine A: draft-changelog
- [ ] Routine created successfully (visible in web UI or CLI)
- [ ] Ran only when manually triggered (one-off)
- [ ] Check run status at https://claude.ai/code/routines
- [ ] Open run transcript and verify:
  - [ ] Git log was read successfully
  - [ ] New branch `changelog-draft` was created
  - [ ] CHANGELOG.md file was written
  - [ ] Curl command for Routine B was provided
- [ ] Green status verified (but remember: check transcript for actual success)

### Routine B: approve-changelog
- [ ] Routine created with API trigger
- [ ] Bearer token generated and stored
- [ ] API trigger endpoint URL obtained
- [ ] Did NOT run before manual API call
- [ ] Fired only via curl command (not automatically)
- [ ] Check run status after API trigger
- [ ] Open run transcript and verify:
  - [ ] Branch `changelog-draft` was found
  - [ ] CHANGELOG.md exists on that branch
  - [ ] Merge to main completed
  - [ ] Commit message matches: "docs: merge approved changelog"
  - [ ] Changes pushed to remote (if applicable)

### Git State Verification
```bash
# Verify branch was created
git branch -a | grep changelog-draft

# Verify merge happened
git log --oneline --grep="merge approved changelog" -5

# Verify CHANGELOG.md exists on main
git checkout main
cat CHANGELOG.md
```

### State File Verification
- [ ] State file exists at `.claude/routine-state.json`
- [ ] State file contains run history for both routines

## Final Verification - The Three Requirements

1. ✅ **Routine B ran ONLY because you fired it**
   - Check: Run history shows API trigger source, not automatic schedule
   - Verify: No runs before your curl command

2. ✅ **Routine B's transcript shows action actually happened**
   - Check: Open the run session
   - Verify: Merge commands executed successfully
   - Verify: Not just "I will do X" but "I did X" with command output

3. ✅ **A6 checklist complete**
   - Connectors pruned: ✅
   - Unrestricted pushes off: ✅
   - State file chosen: ✅

## Notes

- Green status ≠ success. Always check the transcript.
- Bearer tokens are shown only once. Store immediately.
- API triggers are scoped per-routine.
- Run transcripts are permanent and auditable.

## Date Completed

_________________
