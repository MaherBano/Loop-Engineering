# Loop Rules

## File Validation

Before reading or referencing a file in the loop, verify it exists first:

```bash
if [ ! -f "config.yaml" ]; then
  echo "⚠️ SKIPPED: config.yaml does not exist, skipping this check"
  exit 0
fi
```

This prevents "NEEDS HUMAN" alerts for expected files that may not be present in all runs.

## Pattern

1. Check file existence with `-f`
2. If missing, log a skip message (not an error)
3. Exit cleanly with code 0
4. Only proceed with file operations if the file exists

This makes the loop resilient to missing optional files.
