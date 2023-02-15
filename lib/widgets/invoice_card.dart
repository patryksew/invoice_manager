import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:invoice_manager/screens/invoice_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceModel data;
  final VoidCallback refreshFn;

  const InvoiceCard(this.data, this.refreshFn, {super.key});

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
            Text("Nazwa kontrahenta: ${data.contractorName}"),
            Text("Stawka VAT: ${data.vat}%"),
            Text("Kwota netto: ${data.netVal}"),
            Text("Kwota brutto: ${data.grossVal}"),
            Text("Załącznik: ${data.attachmentName}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      final storageInstance = FirebaseStorage.instance;
                      final authInstance = FirebaseAuth.instance;
                      final fileExtension = data.attachmentName.substring(data.attachmentName.lastIndexOf("."));
                      final ref = storageInstance
                          .ref("users/${authInstance.currentUser!.uid}/invoices/${data.id}$fileExtension");
                      ref
                          .getDownloadURL()
                          .then((value) => launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication));
                    },
                    child: const Text("Pobierz załącznik")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => InvoiceScreen.edit(data, refreshFn)));
                    },
                    child: const Text("Edytuj")),
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: ((_) {
                            return AlertDialog(
                              title: const Text("Czy na pewno chcesz usunąć tę fakturę?"),
                              content: const Text("Nie da się tego cofnąć."),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      final storageInstance = FirebaseStorage.instance;
                                      final authInstance = FirebaseAuth.instance;
                                      final firestoreInstance = FirebaseFirestore.instance;
                                      final fileExtension =
                                          data.attachmentName.substring(data.attachmentName.lastIndexOf("."));
                                      storageInstance
                                          .ref(
                                              "users/${authInstance.currentUser!.uid}/invoices/${data.id}$fileExtension")
                                          .delete();
                                      firestoreInstance
                                          .collection("users/${authInstance.currentUser!.uid}/invoices/")
                                          .doc(data.id)
                                          .delete();
                                      refreshFn();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Tak")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Nie")),
                              ],
                            );
                          }));
                    },
                    child: const Text("Usuń")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
