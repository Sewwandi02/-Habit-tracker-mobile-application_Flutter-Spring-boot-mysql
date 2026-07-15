import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app_state.dart';
import 'package:habit_tracker/main.dart';

void main() {
  testWidgets('Landing screen shows the Habit Tracker entry point', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Access AppState and wait for async initialization to complete
    final AppStateScope scope = tester.widget(find.byType(AppStateScope));
    final AppState appState = scope.notifier!;
    while (!appState.isInitialized) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pump(); // rebuild with LandingScreen

    expect(find.text('Welcome to Your Habit Tracker'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
