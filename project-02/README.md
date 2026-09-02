# Project-02: Conditional Loop with Test-Driven Completion

**Difficulty:** Easy to Medium  
**Concepts:** Concept 5 (Conditional Loop), Concept 11 (Maker-Checker)

## Objective

Build a loop that keeps working until tests pass, letting a command (the test runner) decide when it's done—not the agent. Cap iterations to prevent infinite loops. The loop should stop because tests actually passed, not because it hit the iteration limit.

## What Was Built

A simple Python module with deliberately failing tests that were fixed through an iterative loop process:

- **`math_utils.py`**: Contains the `add_numbers()` function that adds two numbers together
- **`test_math_utils.py`**: Contains 3 unit tests for the add_numbers function:
  - `test_add_positive_numbers` - Tests adding positive numbers
  - `test_add_negative_numbers` - Tests adding negative numbers  
  - `test_add_zero` - Tests adding zero to a number

## Key Concepts Demonstrated

### Concept 5: Conditional Loop
The loop continues based on a condition (test results) rather than a fixed number of iterations. It stops when:
- **Success condition**: All tests pass (`pytest` returns exit code 0)
- **Safety cap**: Maximum iteration limit reached (e.g., 6 tries)

### Concept 11: Maker-Checker Pattern
- **Maker**: The agent/developer writes or fixes the code
- **Checker**: The test runner (`pytest`) validates whether the changes are correct
- The checker has final authority—it decides when the work is done

## How It Works

1. **Initial State**: Tests were set up to fail
2. **Loop Process**:
   - Run tests using `pytest`
   - Check exit code (0 = pass, non-zero = fail)
   - If tests fail and iteration count < cap: analyze failures and fix code
   - If tests pass: loop exits successfully
   - If cap reached: loop exits with timeout indication
3. **Success Criteria**: Loop stopped because tests passed, not because cap was hit

## Running the Tests

```bash
# Run tests with pytest
python -m pytest test_math_utils.py -v

# Or using unittest directly
python test_math_utils.py
```

## Current Status

✅ **All tests passing** (3/3)

```
test_math_utils.py::TestAddNumbers::test_add_negative_numbers PASSED
test_math_utils.py::TestAddNumbers::test_add_positive_numbers PASSED
test_math_utils.py::TestAddNumbers::test_add_zero PASSED
```

## Lessons Learned

- **Command-driven completion**: Let external commands (test runners, linters, build tools) determine success, not arbitrary iteration counts
- **Safety caps**: Always include maximum iteration limits to prevent infinite loops
- **Clear exit conditions**: The stop condition must be unambiguous—in this case, `pytest` exit code 0
- **Separation of concerns**: The maker (agent) creates/fixes code; the checker (test runner) validates it independently

## Loop Pattern Template

```python
max_iterations = 6
iteration = 0

while iteration < max_iterations:
    # Run the checker command
    result = subprocess.run(['pytest', 'test_math_utils.py'])
    
    if result.returncode == 0:
        print("✅ Tests passed! Loop complete.")
        break
    else:
        print(f"❌ Tests failed. Iteration {iteration + 1}/{max_iterations}")
        # Analyze and fix issues
        # ...
    
    iteration += 1
else:
    print("⚠️ Hit iteration cap. Stop condition or prompt needs work.")
```

## Dependencies

- Python 3.12+
- pytest 7.4.3

Install with:
```bash
pip install pytest
```

---

**Completion Date:** August 19, 2024  
**Status:** ✅ Complete - Loop stopped on successful test pass
