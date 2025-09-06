import 'package:flutter_test/flutter_test.dart';

// Mock class to test input validation logic without UI dependencies
class MockInputValidator {
  static const Set<int> validInputNumbers = {
    1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
  };

  List<String> parseInput(String input) {
    return input
        .split(RegExp(r'[,\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  bool isValidInputNumber(int number) {
    return validInputNumbers.contains(number);
  }

  List<int> validateAndParseNumbers(String input) {
    List<String> numStrings = parseInput(input);
    List<int> validNumbers = [];

    for (String numStr in numStrings) {
      try {
        int num = int.parse(numStr);
        if (num < 1 || num > 1024) {
          continue; // Invalid range
        }
        if (!isValidInputNumber(num)) {
          continue; // Not power of 2
        }
        validNumbers.add(num);
      } on FormatException {
        continue; // Invalid number format
      }
    }

    return validNumbers;
  }

  bool canAddToSum(int currentSum, List<int> newNumbers) {
    int sumToAdd = newNumbers.reduce((a, b) => a + b);
    const int maxPossibleSum = 2047;
    return currentSum + sumToAdd <= maxPossibleSum;
  }
}

void main() {
  group('Input Validation Tests', () {
    late MockInputValidator validator;

    setUp(() {
      validator = MockInputValidator();
    });

    test('Parse comma separated input', () {
      List<String> result = validator.parseInput("2,4,8");
      expect(result, equals(["2", "4", "8"]));
    });

    test('Parse space separated input', () {
      List<String> result = validator.parseInput("2 4 8");
      expect(result, equals(["2", "4", "8"]));
    });

    test('Parse mixed comma and space input', () {
      List<String> result = validator.parseInput("2, 4 8");
      expect(result, equals(["2", "4", "8"]));
    });

    test('Handle empty input gracefully', () {
      List<String> result = validator.parseInput("   ");
      expect(result, isEmpty);
    });

    test('Handle empty strings after parsing', () {
      List<String> result = validator.parseInput(", ,");
      expect(result, isEmpty);
    });

    test('Valid input numbers validation', () {
      expect(validator.isValidInputNumber(1), true);
      expect(validator.isValidInputNumber(2), true);
      expect(validator.isValidInputNumber(4), true);
      expect(validator.isValidInputNumber(8), true);
      expect(validator.isValidInputNumber(16), true);
      expect(validator.isValidInputNumber(32), true);
      expect(validator.isValidInputNumber(64), true);
      expect(validator.isValidInputNumber(128), true);
      expect(validator.isValidInputNumber(256), true);
      expect(validator.isValidInputNumber(512), true);
      expect(validator.isValidInputNumber(1024), true);
    });

    test('Invalid input numbers validation', () {
      expect(validator.isValidInputNumber(0), false);
      expect(validator.isValidInputNumber(3), false);
      expect(validator.isValidInputNumber(5), false);
      expect(validator.isValidInputNumber(10), false);
      expect(validator.isValidInputNumber(33), false);
      expect(validator.isValidInputNumber(1025), false);
    });

    test('Parse and validate valid inputs', () {
      List<int> result = validator.validateAndParseNumbers("1,2,4,8");
      expect(result, equals([1, 2, 4, 8]));
    });

    test('Filter invalid numbers', () {
      List<int> result = validator.validateAndParseNumbers("1,3,5,8");
      expect(result, equals([1, 8]));
    });

    test('Handle invalid number formats', () {
      List<int> result = validator.validateAndParseNumbers("1,abc,4,def");
      expect(result, equals([1, 4]));
    });

    test('Sum overflow protection test', () {
      // Test valid sum (should work)
      expect(validator.canAddToSum(0, [1024]), true);
      expect(validator.canAddToSum(0, [512, 256, 128, 64, 32, 16, 8, 4, 2, 1]), true);

      // Test sum that would overflow
      expect(validator.canAddToSum(2030, [32]), false); // 2030 + 32 = 2062 > 2047
      expect(validator.canAddToSum(2047, [1]), false);  // 2047 + 1 = 2048 > 2047
    });

    test('Edge case: maximum valid combination', () {
      // All valid numbers sum = 1+2+4+...+1024
      List<int> allNumbers = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024];
      int totalSum = allNumbers.reduce((a, b) => a + b); // 2047
      expect(validator.canAddToSum(0, allNumbers), true);
      expect(validator.canAddToSum(1, allNumbers), false); // Would be 2048
    });

    test('Duplicate number filtering', () {
      // This tests the UI logic but we need to implement this in our tests
      List<int> result = validator.validateAndParseNumbers("2,4,2,8");
      expect(result, equals([2, 4, 8])); // Should not contain duplicates
      // Note: The actual UI handles duplicates, this is just a basic validation test
    });
  });
}