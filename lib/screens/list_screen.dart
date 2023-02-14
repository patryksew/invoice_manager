import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:invoice_manager/widgets/invoice_card.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  bool isLoading = true;
  List<InvoiceModel> data = [];

  Future<void> getData() async {
    final authInstance = FirebaseAuth.instance;
    final firestoreInstance = FirebaseFirestore.instance;

    final response = await firestoreInstance.collection("users/${authInstance.currentUser!.uid}/invoices").get();
    final docs = response.docs;
    for (final doc in docs) {
      data.add(InvoiceModel.parse(doc.data()));
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
    return Scaffold(
      appBar: AppBar(title: const Text("Lista faktur")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: ((context, index) {
                  return InvoiceCard(data[index]);
                })),
      ),
    );
  }
}
