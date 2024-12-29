class Saldo {
  final double saldo;

  Saldo({required this.saldo});

  // factory Saldo.fromJson(Map<String, dynamic> json) {
  //   return Saldo(
  //     saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
  //   );
  // }

  factory Saldo.fromJson(Map<String, dynamic> json) {
    return Saldo(
      saldo:
          double.parse(json['saldo'].toString()) ?? 0.0, // Pastikan parsing ke double
    );
  }

  Map<String, dynamic> toJson() => {
        'saldo': saldo,
      };
}
