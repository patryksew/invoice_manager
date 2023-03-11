import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_manager/invoice_model.dart';
import 'package:invoice_manager/providers/invoices_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class InvoiceScreen extends StatefulWidget {
  final InvoiceModel? data;

  const InvoiceScreen({super.key}) : data = null;

  const InvoiceScreen.edit(this.data, {super.key});

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
  int? vat;
  late final bool isEditMode;
  late final String? documentId;
  late final String? oldAttachmentExtension;
  late AppLocalizations appLocalizations;

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

    final navigator = Navigator.of(context);

    final netNum = num.parse(netVal.text);
    final grossNum = num.parse(grossVal.text);

    final data = InvoiceModel(invoiceNo.text, contractorName.text, netNum, grossNum, attachmentName.text, vat!);

    final invoicesProvider = Provider.of<InvoicesProvider>(context, listen: false);

    if (isEditMode) {
      data.id = documentId;
      await invoicesProvider.updateInvoice(data, attachment, oldAttachmentExtension!);
    } else {
      await invoicesProvider.createInvoice(data, attachment!);
    }

    navigator.pop();
  }

  @override
  void initState() {
    if (widget.data == null) {
      isEditMode = false;
      super.initState();
      return;
    }

    isEditMode = true;
    final data = widget.data!;

    invoiceNo.text = data.invoiceNo;
    contractorName.text = data.contractorName;
    netVal.text = data.netVal.toString();
    grossVal.text = data.grossVal.toString();
    attachmentName.text = data.attachmentName;
    attachment = null;
    setState(() {
      vat = data.vat;
    });
    documentId = data.id;
    oldAttachmentExtension = data.attachmentName.substring(data.attachmentName.lastIndexOf("."));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? appLocalizations.editInvoice : appLocalizations.addNewInvoice),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : submit,
        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextFormField(
                  decoration: decoration.copyWith(labelText: "${appLocalizations.invoiceNo} *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return appLocalizations.thisFieldCantBeEmpty;
                    return null;
                  },
                  controller: invoiceNo,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(labelText: "${appLocalizations.contractorName} *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return appLocalizations.thisFieldCantBeEmpty;
                    return null;
                  },
                  controller: contractorName,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(labelText: "${appLocalizations.netAmount} *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return appLocalizations.thisFieldCantBeEmpty;
                    double? num = double.tryParse(val);
                    if (num == null || num <= 0) return appLocalizations.netAmountMustBeBiggerThan0;
                    return null;
                  },
                  controller: netVal,
                  keyboardType: TextInputType.number,
                  inputFormatters: amountFormatters,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  decoration: decoration.copyWith(labelText: "${appLocalizations.vatRate} *"),
                  value: vat,
                  items: [0, 7, 23]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text("$e%"),
                          ))
                      .toList(),
                  validator: (val) {
                    if (val == null) return appLocalizations.selectVatRate;
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
                  decoration: decoration.copyWith(labelText: "${appLocalizations.grossAmount} *"),
                  validator: (val) {
                    val?.trim();
                    if (val == null || val.isEmpty) return appLocalizations.thisFieldCantBeEmpty;
                    double? num = double.tryParse(val);
                    if (num == null || num <= 0) return appLocalizations.grossAmountMustBeBiggerThan0;
                    return null;
                  },
                  controller: grossVal,
                  keyboardType: TextInputType.number,
                  inputFormatters: amountFormatters,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: decoration.copyWith(
                    labelText: "${appLocalizations.attachment} *",
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
                    if (value == null || value.isEmpty || (attachment == null && !isEditMode)) {
                      return appLocalizations.addAttachment;
                    }
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
