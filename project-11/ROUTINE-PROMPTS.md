# Routine Creation - Copy/Paste Reference

Use this file when creating the routines via web UI or CLI.

## Routine A: draft-changelog

**Name**: `draft-changelog`

**Prompt**:
```
Read the git log for commits from the last 7 days using: git log --since='7 days ago' --pretty=format:'%h - %s (%an, %ar)' --no-merges. Create a draft changelog on a new branch called 'changelog-draft' with these changes formatted nicely in a CHANGELOG.md file. Include sections for Features, Fixes, and Other. At the end of your response, output the curl command needed to trigger the 'approve-changelog' routine.
```

**Schedule**: None (run manually/one-off)

**Triggers**: None

---

## Routine B: approve-changelog

**Name**: `approve-changelog`

**Prompt**:
```
Merge the 'changelog-draft' branch into main. First verify the branch exists and has a CHANGELOG.md file, then perform the merge with a commit message 'docs: merge approved changelog'. Push the changes to remote.
```

**Schedule**: None

**Triggers**: API (you must add this and generate the bearer token)

---

## Creating via Web UI (https://claude.ai/code/routines)

### For Routine A:
1. Click "Create routine"
2. Name: `draft-changelog`
3. Paste the prompt above
4. Leave schedule empty
5. Don't add any triggers
6. Save

### For Routine B:
1. Click "Create routine"
2. Name: `approve-changelog`
3. Paste the prompt above
4. Leave schedule empty
5. Click "Add trigger" → Select "API"
6. Click "Generate token"
7. **COPY THE TOKEN IMMEDIATELY** and save to `bearer-token.txt`
8. Save the routine

---

## Bearer Token Storage

After generating the token, save it immediately:

```bash
echo "YOUR_BEARER_TOKEN_HERE" > bearer-token.txt
```

The token starts with `sk-ant-oat01-` and is shown only once.

---

## API Trigger Endpoint

After creating Routine B with API trigger, you'll get an endpoint like:

```
https://api.anthropic.com/v1/claude_code/routines/trig_XXXXXXXXXXXXXXXXX/fire
```

Save this trigger ID: `trig_XXXXXXXXXXXXXXXXX`

---

## Curl Command Template

Once you have the bearer token and trigger ID:

```bash
curl -X POST https://api.anthropic.com/v1/claude_code/routines/trig_XXXXXXXXXXXXXXXXX/fire \
  -H "Authorization: Bearer sk-ant-oat01-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"text": "Approved for merge"}'
```

Replace:
- `trig_XXXXXXXXXXXXXXXXX` with your actual trigger ID
- `sk-ant-oat01-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` with your actual bearer token

---

## Quick Reference

| Routine | Type | Trigger | Action |
|---------|------|---------|--------|
| draft-changelog | Draft creator | Manual run | Creates changelog on branch |
| approve-changelog | Approver | API (curl) | Merges approved changelog |

**The Gate**: You manually review the draft before firing the API trigger.
