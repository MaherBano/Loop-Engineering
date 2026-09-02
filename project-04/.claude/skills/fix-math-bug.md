---
description: Fix the subtract_numbers bug in math_utils.py
tags: [bug-fix, worktree]
---

You are fixing a bug in `math_utils.py` where `subtract_numbers(a, b)` incorrectly returns `b - a` instead of `a - b`.

## Implementation Steps

1. **Create a worktree** for isolated development:
   - Use `EnterWorktree` with name "fix-subtract-bug"
   - This creates an isolated checkout on a new branch

2. **Apply the fix**:
   - Open `math_utils.py`
   - Find the `subtract_numbers` function (line 24)
   - Change `return b - a` to `return a - b`

3. **Commit the fix**:
   - Stage the change: `git add math_utils.py`
   - Commit with message: "fix: correct subtract_numbers to return a - b"

4. **DO NOT push or create PR yet** - the reviewer agent will handle that

## Expected Output

Return a JSON object with:
```json
{
  "worktree_path": "<path to worktree>",
  "branch_name": "<branch name>",
  "fix_applied": true,
  "commit_sha": "<commit hash>"
}
```
