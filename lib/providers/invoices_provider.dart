import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:invoice_manager/invoice_model.dart';

class InvoicesProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = true;

  List<InvoiceModel> get invoices => [..._invoices];
  bool get isLoading => _isLoading;

  InvoicesProvider() {
    refresh();
  }

  Future<void> removeInvoice(InvoiceModel invoice) async {
    _isLoading = true;
    notifyListeners();
    final storageInstance = FirebaseStorage.instance;
    final authInstance = FirebaseAuth.instance;
    final firestoreInstance = FirebaseFirestore.instance;
    final fileExtension = invoice.attachmentName.substring(invoice.attachmentName.lastIndexOf("."));
    storageInstance.ref("users/${authInstance.currentUser!.uid}/invoices/${invoice.id}$fileExtension").delete();
    firestoreInstance.collection("users/${authInstance.currentUser!.uid}/invoices/").doc(invoice.id).delete();
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    _invoices = [];
    final authInstance = FirebaseAuth.instance;
    final firestoreInstance = FirebaseFirestore.instance;

    final response = await firestoreInstance.collection("users/${authInstance.currentUser!.uid}/invoices").get();
    final docs = response.docs;
    for (final doc in docs) {
      _invoices.add(InvoiceModel.parse(doc.data(), id: doc.id));
    }
    _isLoading = false;
    notifyListeners();
  }
}
