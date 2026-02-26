import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  String? _verificationId;

  /// Send OTP to phone number
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verify if available
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(minutes: 2),
      );
    } catch (e) {
      onError(FirebaseAuthException(
        code: 'error',
        message: e.toString(),
      ));
    }
  }

  /// Sign in with OTP code
  Future<UserCredential?> signInWithOTP(String otp) async {
    try {
      if (_verificationId == null) {
        throw FirebaseAuthException(
          code: 'verification-id-null',
          message: 'Verification ID is null. Request OTP first.',
        );
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Get ID token
  Future<String?> getIdToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  bool get isAuthenticated => _firebaseAuth.currentUser != null;
}
