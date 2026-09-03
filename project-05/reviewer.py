#!/usr/bin/env python3
"""
Reviewer agent that checks if the subtract_numbers bug fix is correct.
Returns PASS (exit code 0) or FAIL (exit code 1) with detailed JSON reasoning.
"""

import sys
import json
from pathlib import Path


def review_fix(file_path: str) -> dict:
    """
    Review the math_utils.py fix.

    Criteria for PASS:
    1. subtract_numbers must return a - b (not b - a)
    2. Function signature must be unchanged
    3. Docstring must be accurate
    4. No recursion or syntax bugs
    5. add_numbers function unchanged

    Returns:
        dict with 'verdict' (PASS/FAIL) and 'reasons' (list of findings)
    """
    reasons = []

    # Read the file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        return {
            "verdict": "FAIL",
            "reasons": [f"File not found: {file_path}"]
        }

    # Check 1: Does subtract_numbers exist?
    if "def subtract_numbers(a, b):" not in content:
        reasons.append("CRITICAL: subtract_numbers function signature changed or missing")
        return {"verdict": "FAIL", "reasons": reasons}

    # Check 2: Extract the function body
    lines = content.split('\n')
    in_subtract_func = False
    return_line = None

    for i, line in enumerate(lines):
        if "def subtract_numbers(a, b):" in line:
            in_subtract_func = True
        elif in_subtract_func and line.strip().startswith("return "):
            return_line = line.strip()
            break
        elif in_subtract_func and line.startswith("def ") and "subtract_numbers" not in line:
            # Hit another function
            break

    if return_line is None:
        reasons.append("CRITICAL: No return statement found in subtract_numbers")
        return {"verdict": "FAIL", "reasons": reasons}

    # Check 3: Verify correct implementation
    if "return a - b" in return_line:
        reasons.append("✓ Correct: subtract_numbers returns a - b")
    elif "return b - a" in return_line:
        reasons.append("CRITICAL: Bug NOT fixed - still returns b - a instead of a - b")
        return {"verdict": "FAIL", "reasons": reasons}
    elif "subtract_numbers(" in return_line:
        reasons.append(f"CRITICAL: Recursive call detected - will cause infinite recursion: {return_line}")
        reasons.append("The fix must directly return a - b, not recursively call itself")
        return {"verdict": "FAIL", "reasons": reasons}
    else:
        reasons.append(f"CRITICAL: Unexpected return statement: {return_line}")
        reasons.append("Expected: return a - b")
        return {"verdict": "FAIL", "reasons": reasons}

    # Check 4: Verify docstring accuracy
    if 'The difference of a and b' in content or 'a minus b' in content.lower():
        reasons.append("✓ Docstring is accurate")
    else:
        reasons.append("WARNING: Docstring might need clarification about a - b")

    # Check 5: Look for suspicious changes
    if "TODO" in content or "FIXME" in content or "HACK" in content:
        reasons.append("WARNING: Found TODO/FIXME/HACK comments")

    # Check 6: Verify add_numbers is unchanged
    if "def add_numbers(a, b):" in content and "return a + b" in content:
        reasons.append("✓ add_numbers function unchanged")
    else:
        reasons.append("CRITICAL: add_numbers function was modified or broken")
        return {"verdict": "FAIL", "reasons": reasons}

    # All checks passed
    return {"verdict": "PASS", "reasons": reasons}


def main():
    if len(sys.argv) != 2:
        print(json.dumps({
            "verdict": "FAIL",
            "reasons": ["Usage: reviewer.py <path_to_math_utils.py>"]
        }))
        sys.exit(1)

    file_path = sys.argv[1]
    result = review_fix(file_path)

    print(json.dumps(result, indent=2))

    # Exit with code 0 for PASS, 1 for FAIL
    sys.exit(0 if result["verdict"] == "PASS" else 1)


if __name__ == "__main__":
    main()
