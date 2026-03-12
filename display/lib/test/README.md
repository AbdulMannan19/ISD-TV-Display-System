# Test Utilities - REMOVE BEFORE PRODUCTION

This folder contains testing utilities that should be removed before deploying to production.

## Files to Remove:
- `test_controls.dart` - Navigation arrows and test buttons overlay

## Steps to Remove Test Features:

1. Delete this entire `test/` folder
2. In `main.dart`, remove the import:
   ```dart
   import 'test/test_controls.dart';
   ```
3. In `main.dart`, remove the TestControls widget from the build method (around line 230):
   ```dart
   TestControls(
     onPrevious: _goToPrevious,
     onNext: _goToNext,
     onTestSilence: _testSilence,
   ),
   ```
4. In `main.dart`, remove the test methods:
   - `_goToPrevious()`
   - `_goToNext()`
   - `_testSilence()`

After removal, the app will run in production mode with no test overlays.
