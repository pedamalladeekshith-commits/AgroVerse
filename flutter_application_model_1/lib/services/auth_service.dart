import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: onVerificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (e) {
      onVerificationFailed(e);
    } catch (e) {
      debugPrint("Error sending OTP: $e");
      onVerificationFailed(
        FirebaseAuthException(
          code: "otp-send-failed",
          message: e.toString(),
        ),
      );
    }
  }

  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error verifying OTP: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
