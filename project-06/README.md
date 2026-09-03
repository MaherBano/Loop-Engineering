# Project 06: Event-Driven PR Review Loop with Connectors

**Difficulty:** Medium  
**Concepts Used:** Concept 7 (Event-Driven Loop), Concept 10 (Connectors)  
**Heartbeat Type:** Event-Driven (`pull_request` triggers: `opened`, `synchronize`)

---

## 1. Overview & Objective

The objective of **Project 06** is to construct an **autonomous, event-driven agent loop** that monitors and reviews repository pull requests without requiring manual invocation. 

By leveraging **Concept 7 (Event-Driven Loops)** and **Concept 10 (Connectors)**, the system connects repository events directly into an LLM-powered review engine. Whenever a developer opens a PR or pushes additional commits to an active PR branch, the event-driven heartbeat fires automatically, analyzes the changed diff, and posts structured code review comments directly to the pull request.

With the completion of this project, all four foundational loop heartbeat models are demonstrated:
1. **In-Session Heartbeat** (Project 01 — `/loop` polling)
2. **Conditional Heartbeat** (Project 02 — test runner exit code completion)
3. **Scheduled Heartbeat** (Project 03 — cron / persistent spine memory)
4. **Event-Driven Heartbeat** (Project 06 — GitHub webhook event triggers)

---

## 2. Project Files & Structure

```
project-06/
├── .github/
│   └── workflows/
│       └── claude-pr-review.yml   # GitHub Actions event-driven review workflow
├── math_utils.py                  # Source code containing deliberately planted bug
└── README.md                      # Comprehensive project documentation
```

### File Breakdown

1. **`.github/workflows/claude-pr-review.yml`**:
   The GitHub Actions workflow definition acting as the connector and event listener.
   - **Triggers**: `on: pull_request: types: [opened, synchronize]`
   - **Permissions**: `contents: read`, `pull-requests: write`
   - **Connector**: `anthropics/claude-code-action@v1`
   - **Prompt**: Configured with strict review rules focused on high-severity defects.

2. **`math_utils.py`**:
   Target source file containing a deliberately planted defect:
   ```python
   def divide_numbers(a, b):
       return b / a  # bug: operands reversed
   ```
   - **Planted Bug 1 (Logic Error / Operand Inversion)**: Function claims to compute $a \div b$ but evaluates $b / a$.
   - **Planted Bug 2 (Missing Zero Check)**: Inverting operands causes a crash (`ZeroDivisionError`) when $a = 0$ instead of when $b = 0$.

---

## 3. Key Concepts Demonstrated

### Concept 7: Event-Driven Heartbeats
In contrast to scheduled loops that tick on a timer (e.g., cron every 5 minutes) or in-session loops that require an active CLI session, an **event-driven loop** awakens exclusively when an external event occurs:
- **`opened` event**: Fires the moment a pull request is initially created. The agent performs an initial pass over the PR diff.
- **`synchronize` event**: Fires whenever new commits are pushed to the PR branch. If the initial review requested revisions or the developer updated the code, pushing changes automatically triggers a re-review loop without any human prompting.

### Concept 10: Connectors
Connectors bridge the agent to external platforms, APIs, and systems:
- **GitHub Actions Connector (`anthropics/claude-code-action@v1`)**: Handles checking out the pull request ref, calculating the unified git diff, formatting the context for Claude, and calling the GitHub Pull Request Review API (`pull-requests: write`) to post inline and top-level review comments.
- **Authentication & Secrets**: Securely injects `ANTHROPIC_API_KEY` and `GITHUB_TOKEN` into the action environment.

---

## 4. Workflow Configuration Deep-Dive

Below is the workflow configuration implemented in `.github/workflows/claude-pr-review.yml`:

```yaml
name: Claude PR Review

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Review PR with Claude
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          prompt: |
            Review this pull request for bugs and code quality issues. Focus especially on:

            1. **Off-by-one errors**: Check array indexing, loop bounds, string slicing, and range calculations
            2. **Missing null/zero checks**: Look for unvalidated inputs, potential null pointer dereferences, division by zero, and missing boundary validations
            3. **Logic errors**: Incorrect conditions, missing edge cases, and control flow issues
            4. **Resource handling**: Unclosed resources, memory leaks, and missing error handling

            For each issue found:
            - Specify the file and line number
            - Explain the bug and its potential impact
            - Suggest a fix

            Provide a clear, actionable review that helps improve code quality and prevent runtime errors.
```

### Review Focus Areas & Prompt Engineering
The review prompt is specifically tuned to catch the core classes of defects:
1. **Off-by-one errors** — array bounds, loop off-by-ones, range boundaries.
2. **Missing null/zero checks** — unvalidated inputs, zero division, null references.
3. **Logic errors** — inverted operators, inverted operands, incorrect condition branching.
4. **Resource handling** — leaks, missing context managers / exception blocks.

---

## 5. How the Event-Driven Loop Operates (Step-by-Step)

```
[Developer]                         [GitHub Event Bus]                 [Claude Code Connector]
     │                                      │                                    │
     ├── 1. Push branch & Open PR ─────────►│                                    │
     │                                      ├── 2. Fire `pull_request: opened` ─►│
     │                                      │                                    ├── 3. Fetch diff & analyze
     │                                      │                                    ├── 4. Detect planted bug in math_utils.py
     │                                      │◄── 5. Post review comment ─────────┤
     │◄── 6. Receive review notifications ──┤                                    │
     │                                      │                                    │
     ├── 7. Push revised fix commit ───────►│                                    │
     │                                      ├── 8. Fire `synchronize` event ────►│
     │                                      │                                    ├── 9. Re-verify updated diff
     │                                      │◄── 10. Post updated approval ──────┤
     ▼                                      ▼                                    ▼
```

1. **PR Creation (`opened`)**:
   A developer branches from `main`, introduces the code in `math_utils.py`, and opens a pull request.
2. **Event Trigger**:
   GitHub triggers the `Claude PR Review` workflow via the `pull_request: opened` webhook.
3. **Diff Analysis**:
   The action executes in an isolated GitHub runner, extracts the git diff, and queries Claude using the structured prompt.
4. **Bug Detection**:
   Claude identifies the defect in `math_utils.py:2`:
   - *Issue*: `divide_numbers(a, b)` returns `b / a` instead of `a / b`.
   - *Impact*: Inverted calculation and unexpected `ZeroDivisionError` when `a == 0`.
   - *Suggested Fix*: Change `return b / a` to `return a / b`, with input check `if b == 0: raise ValueError(...)`.
5. **Automated Review Delivery**:
   Claude posts the findings directly as a PR review without any manual prompting.
6. **Re-Fire on Update (`synchronize`)**:
   When a fix is committed and pushed to the branch, the `synchronize` event automatically re-triggers the workflow to verify the fix.

---

## 6. Comparison of the Four Heartbeat Types

| Project | Heartbeat Type | Trigger Mechanism | State / Memory | Primary Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Project 01** | **In-Session** | `/loop` CLI interval command | Ephemeral (active session) | Monitoring background commands & jobs |
| **Project 02** | **Conditional** | Test runner exit status (`pytest`) | Iteration loop counter + exit code | Autonomous bug fixing until tests pass |
| **Project 03** | **Scheduled** | Cron schedule (`CronCreate` / timer) | Persistent memory spine (`progress.md`) | Recurring repository scans, chore audits |
| **Project 06** | **Event-Driven** | GitHub Webhook (`opened`, `synchronize`) | Git commit SHA & PR diff context | Continuous automated PR code reviews |

---

## 7. Verification & Success Criteria

- [x] **Event Trigger Configured**: GitHub Actions workflow listening on `opened` and `synchronize` pull request events.
- [x] **Connector Implemented**: Integrated `anthropics/claude-code-action@v1` with required permissions (`contents: read`, `pull-requests: write`).
- [x] **Target Bug Planted**: `math_utils.py` contains reversed operands bug in `divide_numbers(a, b)`.
- [x] **Targeted Review Prompt**: Prompt specifically instructs detection of logic errors, zero-checks, off-by-one errors, and outputting line numbers + fixes.
- [x] **Event Re-Fire Capability**: `synchronize` trigger enables automatic re-review upon subsequent push events.
- [x] **Documentation Complete**: `README.md` fully explains concepts, workflow architecture, and execution details.
