class Endpoints {
  static const String baseURLLive = "http://10.0.2.2:8000/api"; // Ganti dengan URL backend Anda
  static String _nim = "1234567890";

  static set nim(String newNim) {
    _nim = newNim;
  }

  static String get nim => _nim;

  static String buildUrl(String path) {
    return '$baseURLLive/$path';
  }

  static String transactionsByNimUrl() {
    return buildUrl('transactions/$nim');
  }

  static String saldoByNimUrl(String newNim) {
    return buildUrl('transactions/saldo/$nim'); // Endpoint untuk saldo
  }

  static String transactionsByNimUrlPost(String nim) {
    return buildUrl('transactions/$nim'); // Endpoint untuk POST (sama dengan GET jika menggunakan method berbeda di backend)
  }

  static String transactionUrl() { // Method untuk POST transaksi
    return buildUrl('transactions');
  }

      static String transactionUpdateUrl(int id) {
        return buildUrl('transactions/$id'); // Method PUT
    }

    static String transactionDeleteUrl(int id) {
        return buildUrl('transactions/$id'); // Method DELETE
    }
}