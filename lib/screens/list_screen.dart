import 'package:flutter/material.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:invoice_manager/providers/invoices_provider.dart';
import 'package:invoice_manager/repositories/auth_repository.dart';
import 'package:invoice_manager/screens/auth_screen.dart';
import 'package:invoice_manager/screens/invoice_screen.dart';
import 'package:invoice_manager/widgets/invoice_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.invoiceList),
        actions: [
          IconButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await AuthRepository.signOut();
                navigator.pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
              },
              icon: const Icon(Icons.logout)),
          IconButton(
              onPressed: Provider.of<InvoicesProvider>(context, listen: false).refresh, icon: const Icon(Icons.refresh))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvoiceScreen()));
        },
      ),
      body: SafeArea(child: Consumer<InvoicesProvider>(builder: (context, invoicesProvider, _) {
        if (invoicesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (invoicesProvider.invoices.isEmpty) {
          return Center(child: Text(appLocalizations.noInvoicesSaved));
        }
        List<InvoiceModel> data = invoicesProvider.invoices;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: ((context, index) {
            return InvoiceCard(data[index]);
          }),
        );
      })),
    );
  }
}
