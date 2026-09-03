---
description: Run parallel fix-and-review workflow across multiple candidate worktrees
---

Run the parallel fix-and-review workflow:

1. Draft fixes across 3 candidate branches in parallel isolated worktrees (good fix, recursive bug fix, unfixed bug)
2. Grade each candidate with the automated reviewer checker
3. Report PASS/FAIL verdicts and diagnostic reasons for each candidate

Execute the workflow script located at `fix-review-workflow.js` or run `./run-candidates.sh`.
