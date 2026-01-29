import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:mymaktaba/screens/home_screen.dart';
import 'package:mymaktaba/screens/account_screen.dart';
import 'package:mymaktaba/services/auth_service.dart';
import 'package:mymaktaba/providers/book_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([AuthService, BookProvider, User])
import 'account_navigation_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockBookProvider mockBookProvider;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockBookProvider = MockBookProvider();
    mockUser = MockUser();

    when(mockBookProvider.savedBooks).thenReturn([]);
    when(mockBookProvider.isLoading).thenReturn(false);
    when(mockBookProvider.loadSavedBooks()).thenAnswer((_) async {});
    when(mockAuthService.currentUser).thenReturn(mockUser);
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.uid).thenReturn('12345');
    when(mockUser.photoURL).thenReturn(null);
  });

  Widget createHomeScreen() {
    return ChangeNotifierProvider<BookProvider>.value(
      value: mockBookProvider,
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  Widget createAccountScreen() {
    return MaterialApp(home: AccountScreen(authService: mockAuthService));
  }

  testWidgets('HomeScreen has Account circle icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
  });

  testWidgets('AccountScreen displays user details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createAccountScreen());

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('12345'), findsOneWidget);
  });

  testWidgets('AccountScreen displays Sign Out button and calls signOut', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createAccountScreen());

    final signOutButton = find.text('Sign Out');
    expect(signOutButton, findsOneWidget);

    when(mockAuthService.signOut()).thenAnswer((_) async {});

    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    verify(mockAuthService.signOut()).called(1);
  });
}
