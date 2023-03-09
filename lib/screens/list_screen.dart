import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:invoice_manager/widgets/invoice_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  bool isLoading = true;
  List<InvoiceModel> data = [];
  late AppLocalizations appLocalizations;

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    data = [];
    final authInstance = FirebaseAuth.instance;
    final firestoreInstance = FirebaseFirestore.instance;

    final response = await firestoreInstance.collection("users/${authInstance.currentUser!.uid}/invoices").get();
    final docs = response.docs;
    for (final doc in docs) {
      data.add(InvoiceModel.parse(doc.data(), id: doc.id));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.invoiceList),
        actions: [IconButton(onPressed: getData, icon: const Icon(Icons.refresh))],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : data.isEmpty
                ? Center(child: Text(appLocalizations.noInvoicesSaved))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: ((context, index) {
                      return InvoiceCard(data[index], getData);
                    })),
      ),
    );
  }
}
