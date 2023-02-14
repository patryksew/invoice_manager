class InvoiceModel {
  String invoiceNo;
  String contractorName;
  double netVal;
  double grossVal;
  String attachmentName;
  int vat;
  String? id;

  InvoiceModel(this.invoiceNo, this.contractorName, this.netVal, this.grossVal, this.attachmentName, this.vat);

  InvoiceModel.parse(Map<String, dynamic> map, {this.id})
      : invoiceNo = map["invoiceNo"],
        contractorName = map["contractorName"],
        netVal = map["netVal"],
        grossVal = map["grossVal"],
        attachmentName = map["attachmentName"],
        vat = map["vat"];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "invoiceNo": invoiceNo,
      "contractorName": contractorName,
      "netVal": netVal,
      "grossVal": grossVal,
      "vat": vat,
      "attachmentName": attachmentName
    };
    return map;
  }
}
