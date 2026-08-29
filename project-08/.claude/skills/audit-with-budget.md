---
name: audit-with-budget
description: Run dependency audit with token budget enforcement
---

# Dependency Audit with Budget Guards

This is a wrapper skill that runs the dependency-audit with strict token limits.

## Budget Limits

- **Per-run cap:** 50,000 tokens (~$5 worst case)
- **Emergency stop:** 45,000 tokens (leave room for cleanup)
- **Typical run:** 5,000-15,000 tokens

## How It Works

1. **Pre-check:** Read current audit-log.md to get baseline token count
2. **Execute:** Run the dependency-audit skill
3. **Post-check:** Estimate tokens used this run
4. **Guard:** If approaching limit, abort and log to spine

## Token Estimation

Rough token counts:
- Reading 100 files: ~20,000 tokens
- Grep results: ~5,000 tokens  
- Writing fixes: ~10,000 tokens
- Creating PR: ~5,000 tokens
- Spine update: ~1,000 tokens

Total typical: ~41,000 tokens (safe)

## Budget Exceeded Response

If token count exceeds 45,000:

```markdown
⚠️ BUDGET EXCEEDED: Used ~XX,XXX tokens (limit: 50,000)

Stopping audit early. Findings so far:
[partial results]

**Next Steps:**
- Review what was found
- Consider splitting audit into smaller scans
- Increase budget if needed
```

## Enforcement

Since we can't measure tokens in real-time perfectly, we rely on:
1. **Proactive limits** - stop after scanning N files
2. **Historical data** - track typical usage in spine
3. **Manual monitoring** - review spine after each run

The skill will self-limit:
- Stop after scanning 50 Python files
- Stop after finding 20 issues
- Stop if fixes grow beyond 10 files

## Usage

From heartbeat schedule:
```bash
/audit-with-budget
```

Or manually:
```bash
claude invoke audit-with-budget
```
