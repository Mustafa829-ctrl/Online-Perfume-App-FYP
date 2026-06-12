class ExpenseModel {
  final String? docId;
  final String? expenseId;
  final String? sellerId;
  final String? title;
  final String? category; // Delivery, Rent, Bills, Packaging, etc.
  final double? amount;
  final String? note;
  final int? createdAt;

  ExpenseModel({
    this.docId,
    this.expenseId,
    this.sellerId,
    this.title,
    this.category,
    this.amount,
    this.note,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        docId: json["docId"],
        expenseId: json["expenseId"],
        sellerId: json["sellerId"],
        title: json["title"],
        category: json["category"],
        amount: (json["amount"] as num?)?.toDouble(),
        note: json["note"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson(String uid) => {
        "docId": uid,
        "expenseId": uid,
        "sellerId": sellerId ?? "",
        "title": title ?? "",
        "category": category ?? "",
        "amount": amount ?? 0.0,
        "note": note ?? "",
        "createdAt": createdAt,
      };
}
