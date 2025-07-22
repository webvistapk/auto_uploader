import 'package:flutter_test/flutter_test.dart';

/// Use this delay if you want a pause between animations
const Duration testDelay = Duration(milliseconds: 50);

/// Waits for the splash screen to complete and transitions to next screen
Future<void> waitForSplashScreen(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await Future.delayed(testDelay);

  await tester.pump(const Duration(seconds: 2));
  await Future.delayed(testDelay);

  await tester.pumpAndSettle();
  await Future.delayed(testDelay);
}