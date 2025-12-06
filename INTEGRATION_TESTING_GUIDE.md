# Integration Testing Guide - Advisor Desk

This document provides comprehensive integration testing strategies for critical user flows in the Advisor Desk application.

## 🎯 Testing Strategy

### Test Pyramid
```
       /\
      /  \     E2E Tests (Few)
     /----\
    /      \   Integration Tests (Some)
   /--------\
  /          \ Unit Tests (Many)
 /____________\
```

## 🧪 Critical User Flows to Test

### 1. Add Daily Entry Flow

**User Story:** As a user, I want to add a daily performance entry with login hours and call count.

**Test Scenario:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:advisor_desk/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Daily Entry Flow', () {
    testWidgets('Complete add entry flow', (tester) async {
      // 1. Launch app
      app.main();
      await tester.pumpAndSettle();

      // 2. Navigate to Add Entry screen
      final addButton = find.byTooltip('Add new entry');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // 3. Fill in login hours
      final hoursField = find.byKey(const Key('login_hours_field'));
      await tester.enterText(hoursField, '8');
      await tester.pumpAndSettle();

      // 4. Fill in login minutes
      final minutesField = find.byKey(const Key('login_minutes_field'));
      await tester.enterText(minutesField, '30');
      await tester.pumpAndSettle();

      // 5. Fill in call count
      final callsField = find.byKey(const Key('call_count_field'));
      await tester.enterText(callsField, '50');
      await tester.pumpAndSettle();

      // 6. Submit form
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 7. Verify success
      expect(find.text('Entry added successfully'), findsOneWidget);
      
      // 8. Verify entry appears in list
      await tester.pumpAndSettle();
      expect(find.text('50'), findsAtLeastNWidgets(1)); // Call count
    });

    testWidgets('Validate required fields', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Add Entry
      await tester.tap(find.byTooltip('Add new entry'));
      await tester.pumpAndSettle();

      // Try to save without filling fields
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify validation errors
      expect(find.text('Please enter login hours'), findsOneWidget);
      expect(find.text('Please enter call count'), findsOneWidget);
    });

    testWidgets('Validate numeric input', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add new entry'));
      await tester.pumpAndSettle();

      // Enter invalid data
      final hoursField = find.byKey(const Key('login_hours_field'));
      await tester.enterText(hoursField, 'abc');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Invalid number'), findsOneWidget);
    });
  });
}
```

### 2. Generate PDF Report Flow

**User Story:** As a user, I want to generate and share a PDF report of my performance.

```dart
group('PDF Report Generation Flow', () {
  testWidgets('Generate and share PDF report', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Navigate to Reports
    await tester.tap(find.byIcon(Icons.description));
    await tester.pumpAndSettle();

    // 2. Select date range
    await tester.tap(find.text('Select Date Range'));
    await tester.pumpAndSettle();

    // Select start date
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Select end date
    await tester.tap(find.text('30'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 3. Generate PDF
    await tester.tap(find.text('Generate PDF'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 4. Verify PDF generated
    expect(find.text('PDF generated successfully'), findsOneWidget);

    // 5. Share PDF
    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    // Verify share sheet appears
    expect(find.text('Share Report'), findsOneWidget);
  });

  testWidgets('Handle empty data scenario', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Clear all data first
    // ... (implementation depends on how data is cleared)

    // Try to generate report with no data
    await tester.tap(find.byIcon(Icons.description));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate PDF'));
    await tester.pumpAndSettle();

    // Verify appropriate message
    expect(find.text('No data available for selected period'), findsOneWidget);
  });
});
```

### 3. Goal Tracking Flow

**User Story:** As a user, I want to set monthly goals and track my progress.

```dart
group('Goal Tracking Flow', () {
  testWidgets('Set and track monthly goals', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Open goals dialog
    await tester.tap(find.byKey(const Key('set_goals_button')));
    await tester.pumpAndSettle();

    // 2. Enter login hours goal
    final hoursGoalField = find.byKey(const Key('hours_goal_field'));
    await tester.enterText(hoursGoalField, '150');
    await tester.pumpAndSettle();

    // 3. Enter calls goal
    final callsGoalField = find.byKey(const Key('calls_goal_field'));
    await tester.enterText(callsGoalField, '1000');
    await tester.pumpAndSettle();

    // 4. Save goals
    await tester.tap(find.text('Save Goals'));
    await tester.pumpAndSettle();

    // 5. Verify goals are displayed
    expect(find.text('150'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);

    // 6. Add entry and verify progress updates
    await tester.tap(find.byTooltip('Add new entry'));
    await tester.pumpAndSettle();

    // Add entry with 10 hours and 50 calls
    await tester.enterText(find.byKey(const Key('login_hours_field')), '10');
    await tester.enterText(find.byKey(const Key('call_count_field')), '50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // 7. Verify progress updated
    // Progress should show (10/150 hours, 50/1000 calls)
    expect(find.textContaining('6.6%'), findsOneWidget); // Hours progress
    expect(find.textContaining('5%'), findsOneWidget); // Calls progress
  });
});
```

### 4. CSAT/CQ Entry Flow

**User Story:** As a user, I want to add quality scores (CSAT and CQ).

```dart
group('Quality Score Entry Flow', () {
  testWidgets('Add CSAT entry', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to Add Entry and switch to CSAT tab
    await tester.tap(find.byTooltip('Add new entry'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CSAT'));
    await tester.pumpAndSettle();

    // Enter CSAT scores
    await tester.enterText(find.byKey(const Key('t2_count_field')), '8');
    await tester.enterText(find.byKey(const Key('b2_count_field')), '1');
    await tester.enterText(find.byKey(const Key('n_count_field')), '1');
    
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify CSAT percentage calculated (80%)
    expect(find.text('80%'), findsOneWidget);
  });

  testWidgets('Add CQ entry', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add new entry'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CQ'));
    await tester.pumpAndSettle();

    // Enter CQ data
    await tester.enterText(find.byKey(const Key('cq_percentage_field')), '95');
    await tester.enterText(find.byKey(const Key('cif_id_field')), 'CIF123');
    
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('CQ entry added'), findsOneWidget);
  });
});
```

### 5. Theme and Settings Flow

**User Story:** As a user, I want to customize app appearance and settings.

```dart
group('Settings and Theme Flow', () {
  testWidgets('Change theme', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Open settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Change to dark theme
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Verify dark theme applied
    // (Implementation depends on theme detection method)
  });

  testWidgets('Update salary parameters', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salary Settings'));
    await tester.pumpAndSettle();

    // Update base rate
    final baseRateField = find.byKey(const Key('base_rate_field'));
    await tester.enterText(baseRateField, '5.50');
    
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Settings saved'), findsOneWidget);
  });
});
```

## 🔧 Setup Integration Tests

### 1. Add Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

### 2. Create Test Directory Structure

```
test_driver/
  integration_test.dart
integration_test/
  add_entry_test.dart
  pdf_report_test.dart
  goal_tracking_test.dart
  quality_score_test.dart
  settings_test.dart
```

### 3. Test Driver File

```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

### 4. Run Tests

```bash
# Run all integration tests
flutter test integration_test

# Run specific test
flutter test integration_test/add_entry_test.dart

# Run on real device
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/add_entry_test.dart
```

## 📊 Test Coverage Goals

- **Unit Tests:** 80%+ coverage
- **Integration Tests:** Cover all critical user flows
- **E2E Tests:** Cover happy path for main features

## 🎯 Testing Best Practices

1. **Use Keys for Widgets:**
   ```dart
   TextField(key: const Key('login_hours_field'))
   ```

2. **Wait for Animations:**
   ```dart
   await tester.pumpAndSettle();
   ```

3. **Test Error Scenarios:**
   - Invalid input
   - Network errors
   - Empty states
   - Permission denied

4. **Test Accessibility:**
   ```dart
   expect(tester.getSemantics(find.byType(Button)).label, 'Save');
   ```

5. **Use Test Data Factories:**
   ```dart
   final testEntry = EntryFactory.create(
     hours: 8,
     calls: 50,
   );
   ```

## 🔍 Continuous Integration

### GitHub Actions Example

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test integration_test
```

## 📝 Test Checklist

- [ ] All critical user flows have integration tests
- [ ] Tests cover happy path scenarios
- [ ] Tests cover error scenarios
- [ ] Tests verify UI state changes
- [ ] Tests verify data persistence
- [ ] Tests are deterministic (no flaky tests)
- [ ] Tests run in CI/CD pipeline
- [ ] Test coverage meets minimum threshold

---

**Last Updated:** December 6, 2024
**Maintained by:** Advisor Desk Development Team
