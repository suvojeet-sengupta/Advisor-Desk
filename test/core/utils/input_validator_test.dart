import 'package:flutter_test/flutter_test.dart';
import 'package:advisor_desk/core/utils/input_validator.dart';

void main() {
  group('InputValidator', () {
    group('isNotEmpty', () {
      test('returns true for non-empty string', () {
        expect(InputValidator.isNotEmpty('test'), true);
      });

      test('returns false for null', () {
        expect(InputValidator.isNotEmpty(null), false);
      });

      test('returns false for empty string', () {
        expect(InputValidator.isNotEmpty(''), false);
      });

      test('returns false for whitespace only', () {
        expect(InputValidator.isNotEmpty('   '), false);
      });
    });

    group('isValidNumber', () {
      test('returns true for valid integer string', () {
        expect(InputValidator.isValidNumber('123'), true);
      });

      test('returns true for valid decimal string', () {
        expect(InputValidator.isValidNumber('123.45'), true);
      });

      test('returns false for non-numeric string', () {
        expect(InputValidator.isValidNumber('abc'), false);
      });

      test('returns false for null', () {
        expect(InputValidator.isValidNumber(null), false);
      });

      test('returns false for empty string', () {
        expect(InputValidator.isValidNumber(''), false);
      });
    });

    group('isValidInteger', () {
      test('returns true for valid integer string', () {
        expect(InputValidator.isValidInteger('123'), true);
      });

      test('returns false for decimal string', () {
        expect(InputValidator.isValidInteger('123.45'), false);
      });

      test('returns false for non-numeric string', () {
        expect(InputValidator.isValidInteger('abc'), false);
      });
    });

    group('isInRange', () {
      test('returns true for value within range', () {
        expect(InputValidator.isInRange(50, 0, 100), true);
      });

      test('returns true for value at minimum bound', () {
        expect(InputValidator.isInRange(0, 0, 100), true);
      });

      test('returns true for value at maximum bound', () {
        expect(InputValidator.isInRange(100, 0, 100), true);
      });

      test('returns false for value below range', () {
        expect(InputValidator.isInRange(-1, 0, 100), false);
      });

      test('returns false for value above range', () {
        expect(InputValidator.isInRange(101, 0, 100), false);
      });

      test('returns false for null', () {
        expect(InputValidator.isInRange(null, 0, 100), false);
      });
    });

    group('isValidLength', () {
      test('returns true for valid length', () {
        expect(InputValidator.isValidLength('test', minLength: 2, maxLength: 10), true);
      });

      test('returns false for too short', () {
        expect(InputValidator.isValidLength('a', minLength: 2, maxLength: 10), false);
      });

      test('returns false for too long', () {
        expect(InputValidator.isValidLength('abcdefghijk', minLength: 2, maxLength: 10), false);
      });

      test('returns true when only minLength specified', () {
        expect(InputValidator.isValidLength('test', minLength: 2), true);
      });

      test('returns true when only maxLength specified', () {
        expect(InputValidator.isValidLength('test', maxLength: 10), true);
      });
    });

    group('isValidEmail', () {
      test('returns true for valid email', () {
        expect(InputValidator.isValidEmail('test@example.com'), true);
      });

      test('returns true for email with subdomain', () {
        expect(InputValidator.isValidEmail('test@mail.example.com'), true);
      });

      test('returns false for email without @', () {
        expect(InputValidator.isValidEmail('testexample.com'), false);
      });

      test('returns false for email without domain', () {
        expect(InputValidator.isValidEmail('test@'), false);
      });

      test('returns false for null', () {
        expect(InputValidator.isValidEmail(null), false);
      });
    });

    group('sanitize', () {
      test('trims whitespace', () {
        expect(InputValidator.sanitize('  test  '), 'test');
      });

      test('removes dangerous characters', () {
        expect(InputValidator.sanitize('<script>alert("xss")</script>'), 'scriptalert(xss)/script');
      });

      test('returns empty string for null', () {
        expect(InputValidator.sanitize(null), '');
      });
    });

    group('parseAndValidateDouble', () {
      test('parses valid double', () {
        expect(InputValidator.parseAndValidateDouble('123.45'), 123.45);
      });

      test('returns default value for invalid input', () {
        expect(InputValidator.parseAndValidateDouble('abc', defaultValue: 0.0), 0.0);
      });

      test('returns default value for value below min', () {
        expect(InputValidator.parseAndValidateDouble('5', min: 10, defaultValue: 10.0), 10.0);
      });

      test('returns default value for value above max', () {
        expect(InputValidator.parseAndValidateDouble('15', max: 10, defaultValue: 10.0), 10.0);
      });

      test('returns parsed value when in range', () {
        expect(InputValidator.parseAndValidateDouble('7.5', min: 5, max: 10), 7.5);
      });
    });

    group('isValidPercentage', () {
      test('returns true for 0', () {
        expect(InputValidator.isValidPercentage(0), true);
      });

      test('returns true for 100', () {
        expect(InputValidator.isValidPercentage(100), true);
      });

      test('returns true for value in range', () {
        expect(InputValidator.isValidPercentage(50.5), true);
      });

      test('returns false for negative value', () {
        expect(InputValidator.isValidPercentage(-1), false);
      });

      test('returns false for value over 100', () {
        expect(InputValidator.isValidPercentage(101), false);
      });
    });

    group('isValidHours', () {
      test('returns true for 0 hours', () {
        expect(InputValidator.isValidHours(0), true);
      });

      test('returns true for 24 hours', () {
        expect(InputValidator.isValidHours(24), true);
      });

      test('returns false for negative hours', () {
        expect(InputValidator.isValidHours(-1), false);
      });

      test('returns false for hours over 24', () {
        expect(InputValidator.isValidHours(25), false);
      });
    });

    group('isNotFutureDate', () {
      test('returns true for past date', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        expect(InputValidator.isNotFutureDate(pastDate), true);
      });

      test('returns true for current date', () {
        final now = DateTime.now();
        expect(InputValidator.isNotFutureDate(now), true);
      });

      test('returns false for future date', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        expect(InputValidator.isNotFutureDate(futureDate), false);
      });

      test('returns false for null', () {
        expect(InputValidator.isNotFutureDate(null), false);
      });
    });

    group('isDateInRange', () {
      test('returns true for date within range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        final date = DateTime(2024, 1, 15);
        expect(InputValidator.isDateInRange(date, start, end), true);
      });

      test('returns true for date at start boundary', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        final date = DateTime(2024, 1, 1);
        expect(InputValidator.isDateInRange(date, start, end), true);
      });

      test('returns true for date at end boundary', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        final date = DateTime(2024, 1, 31);
        expect(InputValidator.isDateInRange(date, start, end), true);
      });

      test('returns false for date before range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        final date = DateTime(2023, 12, 31);
        expect(InputValidator.isDateInRange(date, start, end), false);
      });

      test('returns false for date after range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        final date = DateTime(2024, 2, 1);
        expect(InputValidator.isDateInRange(date, start, end), false);
      });

      test('returns false for null date', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        expect(InputValidator.isDateInRange(null, start, end), false);
      });
    });
  });
}
