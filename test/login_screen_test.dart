import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mymaktaba/screens/login_screen.dart';
import 'package:mymaktaba/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For UserCredential

@GenerateMocks([AuthService, UserCredential])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget createLoginScreen() {
    return MaterialApp(home: LoginScreen(authService: mockAuthService));
  }

  testWidgets('LoginScreen shows email and password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLoginScreen());

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2)); // AppBar and Button
  });

  testWidgets('Tapping Sign Up toggles mode', (WidgetTester tester) async {
    await tester.pumpWidget(createLoginScreen());

    // Initially in Login mode
    expect(find.text('Login'), findsAtLeastNWidgets(1)); // AppBar or Button

    // Tap "Create an account"
    await tester.tap(find.text('Create an account'));
    await tester.pump();

    // Now in Sign Up mode
    expect(find.text('Sign Up'), findsAtLeastNWidgets(1));
  });

  testWidgets('Enter valid credentials calls signIn', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createLoginScreen());

    when(
      mockAuthService.signInWithEmailAndPassword(any, any),
    ).thenAnswer((_) async => MockUserCredential());

    await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    verify(
      mockAuthService.signInWithEmailAndPassword(
        'test@test.com',
        'password123',
      ),
    ).called(1);
  });
}
