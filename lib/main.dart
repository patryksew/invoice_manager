import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:invoice_manager/providers/invoices_provider.dart';
import 'package:invoice_manager/repositories/auth_repository.dart';
import 'package:invoice_manager/screens/auth_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invoice_manager/screens/list_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InvoicesProvider(),
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).invoiceManager,
        locale: const Locale("en"),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthRepository.isUserLoggedIn ? const ListScreen() : const AuthScreen(),
      ),
    );
  }
}
