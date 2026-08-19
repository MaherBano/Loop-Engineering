import unittest
from math_utils import add_numbers


class TestAddNumbers(unittest.TestCase):
    """Tests for the add_numbers function."""

    def test_add_positive_numbers(self):
        """Test adding two positive numbers."""
        result = add_numbers(2, 3)
        self.assertEqual(result, 5)

    def test_add_negative_numbers(self):
        """Test adding two negative numbers."""
        result = add_numbers(-5, -3)
        self.assertEqual(result, -8)

    def test_add_zero(self):
        """Test adding zero to a number."""
        result = add_numbers(10, 0)
        self.assertEqual(result, 10)


if __name__ == '__main__':
    unittest.main()
