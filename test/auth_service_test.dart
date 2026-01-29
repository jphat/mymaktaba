import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mymaktaba/services/auth_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  AppleSignInWrapper,
  UserCredential,
  User,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockAppleSignInWrapper mockAppleSignIn;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockAppleSignIn = MockAppleSignInWrapper();
    authService = AuthService(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
      appleSignIn: mockAppleSignIn,
    );
  });

  group('AuthService Tests', () {
    test('signUpWithEmailAndPassword calls FirebaseAuth', () async {
      when(
        mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => MockUserCredential());

      await authService.signUpWithEmailAndPassword(
        'test@example.com',
        'password',
      );

      verify(
        mockAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).called(1);
    });

    test('signInWithEmailAndPassword calls FirebaseAuth', () async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => MockUserCredential());

      await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password',
      );

      verify(
        mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).called(1);
    });

    test('signOut calls signOut on FirebaseAuth and GoogleSignIn', () async {
      await authService.signOut();

      verify(mockAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });

    test('signInWithGoogle success execution flow', () async {
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUserCredential = MockUserCredential();

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
      when(
        mockGoogleUser.authentication,
      ).thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleAuth.accessToken).thenReturn('release-token');
      when(mockGoogleAuth.idToken).thenReturn('id-token');

      // Note: We can't easily strictly check the exact credential object created inside the method
      // without using a custom matcher or capturing the argument.
      // We will match constraint 'any' for credential.
      when(
        mockAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);

      final result = await authService.signInWithGoogle();

      expect(result, mockUserCredential);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAuth.signInWithCredential(any)).called(1);
    });

    test('signInWithGoogle returns null when cancelled', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await authService.signInWithGoogle();

      expect(result, isNull);
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAuth.signInWithCredential(any));
    });
  });
}
