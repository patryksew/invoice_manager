import 'package:flutter/material.dart';
import 'package:invoice_manager/repositories/auth_repository.dart';
import 'package:invoice_manager/screens/invoice_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;
  bool isWrongPassword = false;
  final formKey = GlobalKey<FormState>();
  final emailFieldKey = GlobalKey<FormFieldState>();
  bool isLoginMode = true;
  String email = '';
  String password = '';

  late AppLocalizations appLocalizations;

  void submit() async {
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
        await AuthRepository.signIn(
          email: email,
          password: password,
          appLocalizations: appLocalizations,
        );
      } else {
        await AuthRepository.signUp(
          email: email,
          password: password,
          appLocalizations: appLocalizations,
        );
      }
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => const InvoiceScreen()));
    } on AuthException catch (e) {
      if (e.code == "wrong-password") {
        isWrongPassword = true;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
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

  void resetPassword() async {
    if (emailFieldKey.currentState == null) return;
    final FormFieldState emailFieldState = emailFieldKey.currentState!;
    if (!emailFieldState.validate()) return;
    emailFieldState.save();

    setState(() {
      isLoading = true;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await AuthRepository.resetPassword(email: email, appLocalizations: appLocalizations);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(appLocalizations.passwordResetLinkSent(email)),
        ),
      );
    } on AuthException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            e.message,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
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
                      key: emailFieldKey,
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
