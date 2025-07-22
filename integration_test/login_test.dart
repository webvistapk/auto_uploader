import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;
import 'package:mobile/screens/authantication/login_screen.dart';
// import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/authantication/check_login_info.dart';
import 'package:mobile/common/app_textfield.dart';
import 'splash_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final Duration testDelay = const Duration(milliseconds: 500);

  group('Login Screen Tests', () {
    final Finder usernameField = find.byWidgetPredicate(
      (widget) => widget is CustomAppTextField && widget.hintText == "Enter email or username",
    );
    final Finder passwordField = find.byWidgetPredicate(
      (widget) => widget is CustomAppTextField && widget.hintText == "Enter password",
    );
    final Finder loginButton = find.text('Log in');
    final Finder loginErrorMessage = find.byKey(const Key('loginErrorMessageText'));

    Future<void> clickLoginButton(WidgetTester tester) async {
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      await Future.delayed(testDelay);
    }
    
    Future<void> typeInInputs(WidgetTester tester, username, password) async {
      await tester.enterText(usernameField, username);
      await Future.delayed(testDelay);
      await tester.enterText(passwordField, password);
      await Future.delayed(testDelay);
    }

    testWidgets('App launches and navigates to login screen after splash', (WidgetTester tester) async {
      app.main();
      await waitForSplashScreen(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Login with empty username/email and empty password shows error', (WidgetTester tester) async {
      app.main();
      await waitForSplashScreen(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      
      await typeInInputs(tester, '', '');
      await clickLoginButton(tester);

      expect(loginErrorMessage, findsOneWidget);
      expect(find.text('Username or Email is required'), findsOneWidget);
    });

    testWidgets('Login with empty username/email shows error', (WidgetTester tester) async {
      app.main();
      await waitForSplashScreen(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await typeInInputs(tester, '', "anypass");
      await clickLoginButton(tester);

      expect(loginErrorMessage, findsOneWidget);
      expect(find.text('Username or Email is required'), findsOneWidget);
    });

    testWidgets('Login with empty password shows error', (WidgetTester tester) async {
      app.main();
      await waitForSplashScreen(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await typeInInputs(tester, 'anyuser', '');
      await clickLoginButton(tester);

      expect(loginErrorMessage, findsOneWidget);
      expect(find.text('Please enter password field'), findsOneWidget);
    });

    testWidgets('Login with incorrect credentials shows error', (WidgetTester tester) async {
      app.main();
      await waitForSplashScreen(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await typeInInputs(tester, 'wronguser', 'wrongpass');
      await clickLoginButton(tester);

      expect(loginErrorMessage, findsOneWidget);
    });

    testWidgets('Successful login with testuser1 and Testpass1 navigates to MainScreen and waits', (WidgetTester tester) async {
      app.main();
      await waitForSplashScreen(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await typeInInputs(tester, 'testuser1', 'Testpass1');
      await clickLoginButton(tester);

      expect(find.byType(CheckLoginInfoScreen), findsOneWidget);

      await Future.delayed(const Duration(seconds: 5));
    });
  });
}