---
name: dependency-audit
description: Audit Python dependencies and documentation across the repository
---

# Dependency & Documentation Audit

You are performing a scheduled audit of the loop-engineering repository to ensure dependencies are documented and README files are current.

## Your Task

### 1. Scan for Python Files
Search the entire repository for `.py` files. For each file:
- Extract all `import` and `from ... import` statements
- Track which external packages are imported (exclude stdlib)
- Note the file path and line numbers

### 2. Check Requirements Files
For each project directory that contains Python files:
- Check if `requirements.txt` exists
- If it exists, verify all external imports are listed
- If it's missing, flag it
- If imports are missing from requirements.txt, flag them

### 3. Verify Documentation
For each project directory:
- Check if `README.md` exists
- If Python files exist but no README, flag it
- If README exists, check if it mentions the main Python modules
- Flag READMEs that seem stale (no mention of existing .py files)

### 4. Generate Report
Write findings to `audit-log.md` in project-08 directory using this format:

```markdown
## YYYY-MM-DD HH:MM

**Findings:**
- Found N Python files across M projects
- X projects missing requirements.txt
- Y undocumented dependencies
- Z projects missing or stale READMEs

**Details:**
[List specific issues found]

**Actions Taken:**
[None | Created requirements.txt | Updated README | etc.]

**Status:** [CLEAN | NEEDS_REVIEW | NEEDS_HUMAN]

**Tokens Used:** ~[estimate]

---
```

### 5. Fix What You Can
If findings are simple and low-risk, fix them:
- ✅ Create missing requirements.txt with discovered imports
- ✅ Add missing imports to existing requirements.txt
- ⚠️ Do NOT modify existing code
- ⚠️ Do NOT update READMEs (too subjective, needs human)

### 6. Create PR if Changes Made
If you made any fixes:
- Commit changes with descriptive message
- Create PR using `gh pr create` with:
  - Title: "chore: dependency audit YYYY-MM-DD"
  - Body: Summary of findings and what was fixed
  - Label: `automated`, `dependencies`

If no changes were made, just update the spine and exit clean.

## Budget Guards

**Stop immediately if:**
- Token count exceeds 50,000 in this run
- You encounter more than 20 issues (too much to fix autonomously)
- Git operations fail (don't retry endlessly)

When stopping due to limits, write to spine:
```
⚠️ BUDGET EXCEEDED: [reason]
```

## Error Handling

If anything fails:
1. Write error to spine with ⚠️ marker
2. Do NOT retry the same operation more than once
3. Commit what you have so far
4. Exit gracefully

Common failures:
- **Malformed Python:** Skip the file, note in spine
- **Git conflicts:** Abort worktree, note in spine  
- **GitHub API errors:** Log to spine, human will review
- **Missing permissions:** Log to spine with clear action needed

## Success Criteria

A successful run:
- ✅ Scans all Python files
- ✅ Documents findings in spine
- ✅ Fixes simple issues automatically
- ✅ Creates PR for human review
- ✅ Stays within token budget
- ✅ Fails visibly when things go wrong

## Notes

- Run this from the repository root
- Worktree isolation handled by caller
- Spine (audit-log.md) is in project-08, always append there
- Be conservative: when in doubt, flag for human review
- The goal is to catch issues, not to be perfect
