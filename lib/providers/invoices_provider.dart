import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoicesProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = true;

  List<InvoiceModel> get invoices => [..._invoices];
  bool get isLoading => _isLoading;

  InvoicesProvider() {
    refresh();
  }

  Future<void> createInvoice(InvoiceModel invoice, PlatformFile attachment) async {
    final storageInstance = FirebaseStorage.instance;
    final authInstance = FirebaseAuth.instance;
    final firestoreInstance = FirebaseFirestore.instance;

    final doc =
        await firestoreInstance.collection("users/${authInstance.currentUser!.uid}/invoices").add(invoice.toMap());

    final ref =
        storageInstance.ref("users/${authInstance.currentUser!.uid}/invoices/${doc.id}.${attachment.extension}");
    await ref.putFile(File(attachment.path!));
    refresh();
  }

  Future<void> deleteInvoice(InvoiceModel invoice) async {
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

  Future<void> updateInvoice(InvoiceModel invoice, PlatformFile? attachment, String oldAttachmentExtension) async {
    final firestoreInstance = FirebaseFirestore.instance;
    final authInstance = FirebaseAuth.instance;

    await firestoreInstance
        .collection("users/${authInstance.currentUser!.uid}/invoices/")
        .doc(invoice.id!)
        .set(invoice.toMap());

    if (attachment != null) {
      final storageInstance = FirebaseStorage.instance;

      final deleteRef =
          storageInstance.ref("users/${authInstance.currentUser!.uid}/invoices/${invoice.id!}$oldAttachmentExtension");
      await deleteRef.delete();

      final uploadRef =
          storageInstance.ref("users/${authInstance.currentUser!.uid}/invoices/{invoice.id!}.${attachment.extension}");
      await uploadRef.putFile(File(attachment.path!));
    }

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

  void openAttachment(InvoiceModel invoice) {
    final storageInstance = FirebaseStorage.instance;
    final authInstance = FirebaseAuth.instance;
    final fileExtension = invoice.attachmentName.substring(invoice.attachmentName.lastIndexOf("."));
    final ref = storageInstance.ref("users/${authInstance.currentUser!.uid}/invoices/${invoice.id}$fileExtension");
    ref.getDownloadURL().then((value) => launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication));
  }
}
