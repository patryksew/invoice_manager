import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_manager/screens/invoice_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  bool isLoginMode = true;
  String email = '';
  String password = '';

  late AppLocalizations appLocalizations;

  void submit() async {
    final authInstance = FirebaseAuth.instance;
    if (formKey.currentState == null) return;
    final FormState formState = formKey.currentState!;
    if (!formState.validate()) return;
    formState.save();
    setState(() {
      isLoading = true;
    });

    final navigator = Navigator.of(context);

    try {
      if (isLoginMode) {
        await authInstance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await authInstance.createUserWithEmailAndPassword(email: email, password: password);
        if (authInstance.currentUser != null) {
          await FirebaseFirestore.instance.collection("users").doc(authInstance.currentUser!.uid).set({});
        }
      }
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => const InvoiceScreen()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Error',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: const ValueKey('email'),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: appLocalizations.emailAddress),
                      validator: (val) {
                        if (val == null || val.isEmpty || !val.contains('@')) {
                          return appLocalizations.enterValidEmail;
                        }
                        return null;
                      },
                      onSaved: (val) {
                        email = val!;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      key: const ValueKey('password'),
                      obscureText: true,
                      decoration: InputDecoration(labelText: appLocalizations.password),
                      validator: (val) {
                        if (val == null || val.length < 7) {
                          return appLocalizations.passwordAtLeast7Chars;
                        }
                        return null;
                      },
                      onSaved: (val) {
                        password = val!;
                      },
                    ),
                    const SizedBox(height: 12),
                    if (isLoading) const CircularProgressIndicator(),
                    if (!isLoading)
                      ElevatedButton(
                        onPressed: () => submit(),
                        child: Text(isLoginMode ? appLocalizations.signIn : appLocalizations.signUp),
                      ),
                    if (!isLoading)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoginMode = !isLoginMode;
                          });
                        },
                        child: Text(
                            isLoginMode ? appLocalizations.createNewAccount : appLocalizations.iAlreadyHaveAccount),
                      ),
                    if (isWrongPassword && !isLoading)
                      TextButton(
                        onPressed: () => resetPassword(),
                        child: Text(appLocalizations.forgotPassword),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
