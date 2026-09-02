# Project 10: Environment Variables vs .env Files

## Objective
Understand why gitignored `.env` files don't work in cloud routines, and how to properly provide secrets via environment variables.

## Setup

### First Run (Will Fail)
1. The API_TOKEN is stored in `.env` (gitignored)
2. Run the routine: `check-token.md`
3. Observe that Claude cannot find the token
4. Review the transcript to see what Claude tried

### Second Run (Will Succeed)
1. Add API_TOKEN to environment variables panel in Claude Code
2. Update the routine with: "credentials are available as environment variables; do not look for a .env file."
3. Run the routine again
4. Observe Claude successfully reads the token from environment

## Test Results Summary

### First Run: .env File Approach ❌
- **Locally:** Works fine - file exists and token is readable
- **In Cloud:** Fails - `.env` is gitignored, never reaches GitHub, so cloud clone has no file

### Second Run: Environment Variable Approach ✅
- **Locally:** Works - reads from environment
- **In Cloud:** Works - environment variables are injected directly into runtime

## The Key Insight

**Why the first run fails in cloud:**
1. `.gitignore` prevents `.env` from being committed to git
2. When routines run in the cloud, they work with a fresh clone from GitHub
3. Gitignored files never reach GitHub, so the cloud clone never contains them
4. Claude has no `.env` file to read in the cloud environment

**Why the second run succeeds:**
1. Environment variables are injected directly into the execution environment
2. They bypass git entirely - no commit/push/clone cycle needed
3. Claude can access them via standard environment variable APIs
4. This is the correct pattern for secrets in cloud environments

**The mechanical reason:** Gitignored files exist only in your local working directory. Git never tracks them, GitHub never receives them, and fresh clones never contain them. Environment variables sidestep this entirely by being injected at runtime.

## Files

- `check-token.md` - The routine that needs the secret
- `.env` - Local file with dummy token (gitignored, won't reach cloud)
- `.gitignore` - Ensures .env stays local
- `README.md` - This documentation
