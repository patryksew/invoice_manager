import 'package:flutter/material.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:invoice_manager/providers/invoices_provider.dart';
import 'package:invoice_manager/screens/invoice_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceModel data;

  const InvoiceCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${appLocalizations.invoiceNo}: ${data.invoiceNo}"),
            Text("${appLocalizations.contractorName}: ${data.contractorName}"),
            Text("${appLocalizations.vatRate}: ${data.vat}%"),
            Text("${appLocalizations.netAmount}: ${data.netVal}"),
            Text("${appLocalizations.grossAmount}: ${data.grossVal}"),
            Text("${appLocalizations.attachment}: ${data.attachmentName}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Provider.of<InvoicesProvider>(context, listen: false).openAttachment(data);
                    },
                    child: Text(appLocalizations.downloadAttachment)),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvoiceScreen.edit(data)));
                    },
                    child: Text(appLocalizations.edit)),
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: ((_) {
                            return AlertDialog(
                              title: Text(appLocalizations.areYouSureYouWantToDeleteInvoice),
                              content: Text(appLocalizations.itIsIrreversible),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();

                                      Provider.of<InvoicesProvider>(context, listen: false).deleteInvoice(data);
                                    },
                                    child: Text(appLocalizations.yes)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(appLocalizations.no)),
                              ],
                            );
                          }));
                    },
                    child: Text(appLocalizations.delete)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
