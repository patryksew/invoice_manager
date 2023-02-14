import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:invoice_manager/screens/list_screen.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  InvoiceScreen.edit({super.key}) {}

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController invoiceNo = TextEditingController();
  TextEditingController contractorName = TextEditingController();
  TextEditingController netVal = TextEditingController();
  TextEditingController grossVal = TextEditingController();
  TextEditingController attachmentName = TextEditingController();
  bool isLoading = false;
  PlatformFile? attachment;
  int vat = 0;

  InputDecoration decoration = InputDecoration(
    filled: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
    errorBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.red)),
  );

  final amountFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'\d+[,.]{0,1}\d{0,2}')),
    TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text.replaceAll(",", ".");

      return newValue.copyWith(text: newText);
    }),
    TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;
      var index = text.indexOf(".");

      if (index > -1 && index + 3 <= text.length) {
        text = text.substring(0, index + 3);
      }

      var offset = newValue.selection.baseOffset;
      offset = min(offset, text.length);

      var result = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: offset));
      return result;
    }),
  ];

  Future<void> submit() async {
    if (formKey.currentState == null) return;
    FormState formState = formKey.currentState!;
    if (!formState.validate()) return;
    formState.save();
    setState(() {
      isLoading = true;
    });

    final firestoreInstance = FirebaseFirestore.instance;

    final netNum = double.parse(netVal.text);
    final grossNum = double.parse(grossVal.text);

    final Map<String, dynamic> data =
        InvoiceModel(invoiceNo.text, contractorName.text, netNum, grossNum, attachmentName.text, vat).toMap();

    final authInstance = FirebaseAuth.instance;
    final doc = await firestoreInstance.collection("users/${authInstance.currentUser!.uid}/invoices").add(data);

    final storageInstance = FirebaseStorage.instance;
    final ref =
        storageInstance.ref("users/${authInstance.currentUser!.uid}/invoices/${doc.id}.${attachment!.extension}");

    await ref.putFile(File(attachment!.path!));
    clearForm();
  }

  void clearForm() {
    print("DUPA");
    isLoading = false;
    formKey.currentState!.reset();
    invoiceNo.clear();
    contractorName.clear();
    netVal.clear();
    grossVal.clear();
    attachmentName.clear();
    attachment = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager faktur"),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ListScreen()));
            },
            icon: const Icon(Icons.list)),
        actions: [
          IconButton(onPressed: isLoading ? null : submit, icon: const Icon(Icons.save)),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  "Dodaj nową fakturę",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(labelText: "Nr faktury *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return "To pole nie może być puste";
                    return null;
                  },
                  controller: invoiceNo,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(labelText: "Nazwa kontrahenta *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return "To pole nie może być puste";
                    return null;
                  },
                  controller: contractorName,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(labelText: "Kwota netto *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return "To pole nie może być puste";
                    double? num = double.tryParse(val);
                    if (num == null || num <= 0) return "Kwota netto musi być większa od 0";
                    return null;
                  },
                  controller: netVal,
                  keyboardType: TextInputType.number,
                  inputFormatters: amountFormatters,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  decoration: decoration.copyWith(labelText: "Stawka VAT *"),
                  items: [0, 7, 23]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text("$e%"),
                          ))
                      .toList(),
                  validator: (val) {
                    if (val == null) return "Wybierz stawkę VAT";
                    return null;
                  },
                  onChanged: (val) {
                    if (val == null) return;
                    vat = val;
                    double? netValNum = double.tryParse(netVal.text);
                    if (netValNum == null) return;
                    grossVal.text = (netValNum * (1 + val / 100)).toStringAsFixed(2);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(labelText: "Kwota brutto *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return "To pole nie może być puste";
                    double? num = double.tryParse(val);
                    if (num == null || num <= 0) return "Kwota brutto musi być większa od 0";
                    return null;
                  },
                  controller: grossVal,
                  keyboardType: TextInputType.number,
                  inputFormatters: amountFormatters,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(
                    labelText: "Załącznik *",
                    prefixIcon: IconButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result == null) return;
                        attachment = result.files.single;
                        attachmentName.text = attachment?.name ?? "";
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  controller: attachmentName,
                  validator: (value) {
                    if (value == null || value.isEmpty || attachment == null) return "Dodaj załącznik";
                    return null;
                  },
                  readOnly: true,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
