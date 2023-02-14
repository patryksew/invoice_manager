import 'package:flutter/material.dart';
import 'package:invoice_manager/invoice_model.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceModel data;

  const InvoiceCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Numer faktury: ${data.invoiceNo}"),
            Text("Nazwa kontrahenta${data.contractorName}"),
            Text("Stawka VAT: ${data.vat}%"),
            Text("Kwota netto: ${data.netVal}"),
            Text("Kwota brutto: ${data.grossVal}"),
            Text("Załącznik: ${data.attachmentName}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: const Text("Pobierz załącznik")),
                TextButton(onPressed: () {}, child: const Text("Edytuj fakturę")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
