#!/bin/bash
# Project 11: Quick Start Script

echo "=== Project 11: Human Gate with API Triggers ==="
echo ""

# Check if we're in the right directory
if [ ! -f ".claude/routines.json" ]; then
    echo "Error: Not in project-11 directory or .claude/routines.json missing"
    exit 1
fi

echo "Step 1: Creating Routine A (draft-changelog)"
echo "-------------------------------------------"
echo "You need to create this routine via the web UI or an interactive Claude session:"
echo ""
echo "Option 1: Web UI"
echo "  1. Go to: https://claude.ai/code/routines"
echo "  2. Click 'Create routine'"
echo "  3. Name: draft-changelog"
echo "  4. Prompt: Read the git log for commits from the last 7 days using: git log --since='7 days ago' --pretty=format:'%h - %s (%an, %ar)' --no-merges. Create a draft changelog on a new branch called 'changelog-draft' with these changes formatted nicely in a CHANGELOG.md file. Include sections for Features, Fixes, and Other. At the end of your response, output the curl command needed to trigger the 'approve-changelog' routine."
echo ""
echo "Option 2: Interactive CLI"
echo "  Run: claude"
echo "  Then: /schedule create"
echo ""
read -p "Press Enter when Routine A is created..."

echo ""
echo "Step 2: Creating Routine B (approve-changelog) with API Trigger"
echo "--------------------------------------------------------------"
echo "  1. Go to: https://claude.ai/code/routines"
echo "  2. Click 'Create routine'"
echo "  3. Name: approve-changelog"
echo "  4. Prompt: Merge the 'changelog-draft' branch into main. First verify the branch exists and has a CHANGELOG.md file, then perform the merge with a commit message 'docs: merge approved changelog'. Push the changes to remote."
echo "  5. Add trigger → API"
echo "  6. Generate token → COPY IT IMMEDIATELY"
echo "  7. Save token to: bearer-token.txt"
echo ""
read -p "Press Enter when Routine B is created and token is saved..."

# Check if bearer token was saved
if [ ! -f "bearer-token.txt" ]; then
    echo "Warning: bearer-token.txt not found. Make sure to save it!"
    read -p "Enter your bearer token now: " BEARER_TOKEN
    echo "$BEARER_TOKEN" > bearer-token.txt
    echo "Token saved to bearer-token.txt"
fi

echo ""
echo "Step 3: Running Routine A"
echo "------------------------"
echo "Go to https://claude.ai/code/routines and click 'Run now' on draft-changelog"
echo ""
read -p "Press Enter when Routine A has completed..."

echo ""
echo "Step 4: Review the Draft"
echo "-----------------------"
git fetch 2>/dev/null
if git show-ref --verify --quiet refs/heads/changelog-draft || git show-ref --verify --quiet refs/remotes/origin/changelog-draft; then
    git checkout changelog-draft 2>/dev/null || git checkout -b changelog-draft origin/changelog-draft 2>/dev/null
    echo ""
    if [ -f "CHANGELOG.md" ]; then
        echo "CHANGELOG.md contents:"
        echo "====================="
        cat CHANGELOG.md
        echo ""
    else
        echo "Warning: CHANGELOG.md not found on changelog-draft branch"
    fi
else
    echo "Warning: changelog-draft branch not found. Check the routine transcript."
fi

echo ""
read -p "Review complete. Approve the changelog? (y/n): " APPROVE

if [ "$APPROVE" != "y" ]; then
    echo "Approval cancelled. Exiting."
    exit 0
fi

echo ""
echo "Step 5: Fire Routine B via API Trigger"
echo "-------------------------------------"
if [ ! -f "bearer-token.txt" ]; then
    echo "Error: bearer-token.txt not found"
    exit 1
fi

BEARER_TOKEN=$(cat bearer-token.txt)
read -p "Enter your trigger ID (trig_...): " TRIGGER_ID

echo ""
echo "Firing Routine B..."
curl -X POST "https://api.anthropic.com/v1/claude_code/routines/$TRIGGER_ID/fire" \
  -H "Authorization: Bearer $BEARER_TOKEN" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"text": "Approved for merge - fired via quick-start script"}'

echo ""
echo ""
echo "Step 6: Verify the Merge"
echo "-----------------------"
echo "Wait a moment for Routine B to complete, then check:"
echo "  1. https://claude.ai/code/routines (verify Routine B ran)"
echo "  2. Open the run transcript to see the actual merge"
echo ""
read -p "Press Enter to check local git state..."

git checkout main
git pull 2>/dev/null

if [ -f "CHANGELOG.md" ]; then
    echo ""
    echo "✅ CHANGELOG.md found on main branch"
    echo ""
    echo "Recent commits:"
    git log --oneline -5
else
    echo "⚠️  CHANGELOG.md not found on main. Check the routine transcript."
fi

echo ""
echo "=== Project 11 Execution Complete ==="
echo ""
echo "Next: Run through the A6-CHECKLIST.md to verify all requirements"
echo "See A6-CHECKLIST.md for detailed verification steps"
