def add_numbers(a, b):
    """Add two numbers together.

    Args:
        a: First number
        b: Second number

    Returns:
        The sum of a and b
    """
    return a + b


def subtract_numbers(a, b):
    """Subtract two numbers.

    Args:
        a: First number
        b: Second number

    Returns:
        The difference of a and b
    """
    return a - b


def multiply_numbers(a, b):
    """Multiply two numbers.

    Args:
        a: First number
        b: Second number

    Returns:
        The product of a and b
    """
    return a * b


def divide_numbers(a, b):
    """Divide two numbers.

    Args:
        a: First number (numerator)
        b: Second number (denominator)

    Returns:
        The quotient of a divided by b
    """
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
