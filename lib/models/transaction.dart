// class Transaction {
//   final String type;
//   final double amount;
//   final String date;
//   final String description; 

//   Transaction({required this.type, required this.amount, required this.date, required this.description,});

//   factory Transaction.fromJson(Map<String, dynamic> json) {
//     return Transaction(
//       type: json['type'] ?? '',
//       amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // Handle null dan parsing ke double
//       date: json['date'] ?? '',
//       description: json['description'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'type': type,
//     'amount': amount,
//     'date': date,
//   };
// }

class Transaction {
  final String id; // Properti id
  final String nim; // Properti
  final String type;
  final double amount;
  final String description;
  final String date;

  Transaction({
    required this.id,
    required this.nim,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

    factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(), // Pastikan id di parse ke string
      nim: json['nim'],
      type: json['type'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      date: json['date'],
    );
  }
}