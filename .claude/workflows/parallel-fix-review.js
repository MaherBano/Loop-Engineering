export const meta = {
  name: 'parallel-fix-review',
  description: 'Draft fixes for multiple candidates in parallel worktrees and grade each',
  phases: [
    { title: 'Fix', detail: 'Apply candidate fixes in isolated worktrees' },
    { title: 'Review', detail: 'Grade each candidate with reviewer checker' },
  ],
}

const CANDIDATES = [
  {
    id: 'good-fix',
    description: 'Correct fix: change return b - a to return a - b',
    prompt: `You are fixing the subtract_numbers bug in math_utils.py.

TASK:
1. Enter a worktree named "candidate-good-fix"
2. Edit math_utils.py and change subtract_numbers to return a - b
3. Commit with message "fix: correct subtract_numbers to return a - b"
4. Return JSON with worktree path, branch name, and whether fix was applied`,
  },
  {
    id: 'bad-recursive',
    description: 'Bad fix: recursive call causing infinite recursion',
    prompt: `You are fixing the subtract_numbers bug in math_utils.py.

TASK:
1. Enter a worktree named "candidate-bad-recursive"
2. Edit math_utils.py and change subtract_numbers to: return subtract_numbers(b, a)
3. Commit with message "fix: attempt recursive approach for subtract_numbers"
4. Return JSON with worktree path, branch name, and whether fix was applied`,
  },
  {
    id: 'bad-unfixed',
    description: 'Bad fix: leaves bug unfixed',
    prompt: `You are fixing the subtract_numbers bug in math_utils.py.

TASK:
1. Enter a worktree named "candidate-bad-unfixed"
2. Leave the bug unfixed: return b - a
3. Commit with message "chore: review subtract_numbers function"
4. Return JSON with worktree path, branch name, and whether fix was applied`,
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

phase('Review')
const results = await pipeline(
  CANDIDATES.map((c, i) => ({ candidate: c, fix: fixes[i] })),
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
1. subtract_numbers must return a - b
2. Function signature must be unchanged
3. No recursion
4. add_numbers unchanged`

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

const passed = results.filter(r => r.review_result?.verdict === 'PASS')
const failed = results.filter(r => r.review_result?.verdict === 'FAIL')

log(`Results: ${passed.length} PASS, ${failed.length} FAIL`)

return {
  summary: {
    total: CANDIDATES.length,
    passed: passed.length,
    failed: failed.length,
  },
  results: results,
}
