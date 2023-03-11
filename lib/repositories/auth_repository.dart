import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({required this.message, required this.code});
}

class AuthRepository {
  static bool get isUserLoggedIn => FirebaseAuth.instance.currentUser != null;

  static Future<void> signIn({
    required String email,
    required String password,
    required AppLocalizations appLocalizations,
  }) async {
    try {
      final authInstance = FirebaseAuth.instance;

      await authInstance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: translateErrorMessage(code: e.code, appLocalizations: appLocalizations),
        code: e.code,
      );
    }
  }

  static Future<void> signUp({
    required String email,
    required String password,
    required AppLocalizations appLocalizations,
  }) async {
    try {
      final authInstance = FirebaseAuth.instance;

      await authInstance.createUserWithEmailAndPassword(email: email, password: password);
      if (authInstance.currentUser != null) {
        await FirebaseFirestore.instance.collection("users").doc(authInstance.currentUser!.uid).set({});
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: translateErrorMessage(code: e.code, appLocalizations: appLocalizations),
        code: e.code,
      );
    }
  }

  static Future<void> resetPassword({required String email, required AppLocalizations appLocalizations}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: translateErrorMessage(code: e.code, appLocalizations: appLocalizations),
        code: e.code,
      );
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static String translateErrorMessage({required String code, required AppLocalizations appLocalizations}) {
    switch (code) {
      case "wrong-password":
        return appLocalizations.wrongPassword;
      case "email-already-in-use":
        return appLocalizations.emailAlreadyInUse;
      case "invalid-email":
        return appLocalizations.invalidEmail;
      case "user-not-found":
        return appLocalizations.userNotFound;
      case "network-request-failed":
        return appLocalizations.networkRequestFailed;
      default:
        return appLocalizations.unexpectedError(code);
    }
  }
}
