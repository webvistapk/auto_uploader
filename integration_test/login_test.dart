import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;
import 'package:mobile/screens/authantication/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and navigates to login screen, then waits', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();    
    await tester.pump(const Duration(seconds: 2));    
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await Future.delayed(const Duration(seconds: 5));
  });
}