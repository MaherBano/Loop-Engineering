export const meta = {
  name: 'parallel-fix-review',
  description: 'Draft fixes for multiple issues in parallel worktrees and grade each',
  phases: [
    { title: 'Fix', detail: 'Apply fixes in isolated worktrees' },
    { title: 'Review', detail: 'Grade each fix with reviewer' },
  ],
}

// Define the candidate fixes we want to test
const CANDIDATES = [
  {
    id: 'good-fix',
    description: 'Correct fix: change return b - a to return a - b',
    prompt: `You are fixing the subtract_numbers bug in math_utils.py.

TASK:
1. Enter a worktree named "candidate-good-fix"
2. Edit math_utils.py and change the subtract_numbers function to return a - b (correct fix)
3. Commit with message "fix: correct subtract_numbers to return a - b"
4. Return JSON with worktree path, branch name, and whether fix was applied

Do NOT push or create PR - just apply fix and commit.`,
  },
  {
    id: 'bad-recursive',
    description: 'Bad fix: recursive call causing infinite recursion',
    prompt: `You are fixing the subtract_numbers bug in math_utils.py.

TASK:
1. Enter a worktree named "candidate-bad-recursive"
2. Edit math_utils.py and change subtract_numbers to: return subtract_numbers(b, a)
3. Commit with message "fix: attempt recursive approach for subtract_numbers"
4. Return JSON with worktree path, branch name, and whether fix was applied

Do NOT push or create PR - just apply fix and commit.`,
  },
  {
    id: 'bad-unchanged',
    description: 'Bad fix: leaves bug unfixed',
    prompt: `You are fixing the subtract_numbers bug in math_utils.py.

TASK:
1. Enter a worktree named "candidate-bad-unchanged"
2. Enter the worktree but do NOT change the subtract_numbers function - leave it returning b - a
3. Add a comment above the function saying "# Reviewed - looks correct"
4. Commit with message "chore: review subtract_numbers function"
5. Return JSON with worktree path, branch name, and note that no functional change was made

Do NOT push or create PR.`,
  },
]

const FIX_SCHEMA = {
  type: 'object',
  properties: {
    worktree_path: { type: 'string' },
    branch_name: { type: 'string' },
    fix_applied: { type: 'boolean' },
    notes: { type: 'string' },
  },
  required: ['worktree_path', 'branch_name', 'fix_applied'],
}

const REVIEW_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['PASS', 'FAIL'] },
    reasons: {
      type: 'array',
      items: { type: 'string' },
    },
  },
  required: ['verdict', 'reasons'],
}

log(`Starting parallel fix-and-review for ${CANDIDATES.length} candidates`)

// Phase 1: Apply all fixes in parallel, each in isolated worktree
phase('Fix')
const fixes = await parallel(
  CANDIDATES.map(candidate => () =>
    agent(candidate.prompt, {
      label: `fix:${candidate.id}`,
      phase: 'Fix',
      schema: FIX_SCHEMA,
      isolation: 'worktree',
    })
  )
)

// Phase 2: Review each fix immediately after it's applied (pipeline pattern)
// This allows reviews to start as soon as their fix completes
phase('Review')
const results = await pipeline(
  CANDIDATES.map((c, i) => ({ candidate: c, fix: fixes[i] })),

  // Stage 1: Review the fix
  async ({ candidate, fix }) => {
    if (!fix) {
      return {
        candidate_id: candidate.id,
        description: candidate.description,
        fix_result: null,
        review_result: null,
        error: 'Fix agent failed',
      }
    }

    const reviewPrompt = `Review the fix in ${fix.worktree_path}/math_utils.py

Use the following criteria:
1. subtract_numbers must return a - b (not b - a)
2. Function signature must be unchanged
3. No recursive calls
4. add_numbers function must be unchanged

Read the file and return your verdict as JSON.`

    const review = await agent(reviewPrompt, {
      label: `review:${candidate.id}`,
      phase: 'Review',
      schema: REVIEW_SCHEMA,
    })

    return {
      candidate_id: candidate.id,
      description: candidate.description,
      fix_result: fix,
      review_result: review,
    }
  }
)

// Summarize results
const passed = results.filter(r => r.review_result?.verdict === 'PASS')
const failed = results.filter(r => r.review_result?.verdict === 'FAIL')
const errored = results.filter(r => !r.review_result)

log(`Results: ${passed.length} PASS, ${failed.length} FAIL, ${errored.length} ERROR`)

return {
  summary: {
    total: CANDIDATES.length,
    passed: passed.length,
    failed: failed.length,
    errored: errored.length,
  },
  results: results,
}
