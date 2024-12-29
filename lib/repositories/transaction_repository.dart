import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_pencatatan/endpoints/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/saldo.dart';
import 'dart:developer';

class TransactionRepository {
  Future<List<Transaction>> getTransactions() async {
    final url = Endpoints.transactionsByNimUrl();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception(
            'Gagal mengambil transaksi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil transaksi: $e');
    }
  }

  Future<Saldo> getSaldo(String nim) async {
    final url = Endpoints.saldoByNimUrl(nim); // Menggunakan parameter nim
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return Saldo.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Gagal mengambil saldo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil saldo: $e');
    }
  }

  // Future<void> postTransaction(Transaction transaction, String nim) async {
  //   final url = Endpoints.transactionsByNimUrlPost(nim); // Endpoint untuk POST
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(transaction.toJson()),
  //     );

  //     if (response.statusCode != 201) {
  //       // Periksa status code 201 Created
  //       throw Exception(
  //           'Gagal menambahkan transaksi: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error saat menambahkan transaksi: $e');
  //   }
  // }

  Future<void> addTransaction(
    String nim,
    String type,
    double amount,
    String description,
    String date,
  ) async {
    final url = Uri.parse(Endpoints.transactionUrl());
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'nim': Endpoints.nim
            .toString(), // Sesuaikan tipe data sesuai kebutuhan backend
        'type': type,
        'amount': amount,
        'description': description,
        'date': date, // Sesuaikan tipe data sesuai kebutuhan backend
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // print('Response Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      throw Exception('Gagal menambahkan transaksi: ${response.body}');
    }
  }

// Sesuaikan kode reduceTransaction yang disesuaikan serupai addTransaction
  Future<void> reduceTransaction(
    String nim,
    String type,
    double amount,
    String description,
    String date,
  ) async {
    final url = Uri.parse(Endpoints.transactionUrl());
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'nim': Endpoints.nim
            .toString(), // Sesuaikan tipe data sesuai kebutuhan backend
        'type': type,
        'amount': amount,
        'description': description,
        'date': date, // Sesuaikan tipe data sesuai kebutuhan backend
      }),
    );
    // ... handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Berhasil
      // print("reduceTransaction dipanggil dengan:");
      // print("NIM: $nim, Type: $type, Amount: $amount, Description: $description, Date: $date");
      // print('Transaksi berhasil: ${response.body}');
    } else {
      // Gagal
      // print('Gagal melakukan transaksi: ${response.statusCode}');
      // print('Response body: ${response.body}');
      throw Exception('Gagal melakukan transaksi');
    }
  }

  Future<void> updateTransaction(int id, String nim, String type, double amount,
      String description, String date) async {
    final url =
        Uri.parse('${Endpoints.transactionUrl()}/$id'); // Tambahkan ID ke URL
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode({
              'nim': nim,
              'type': type,
              'amount': amount,
              'description': description,
              'date': date,
            }),
          )
          .timeout(const Duration(seconds: 10)); // Tambahkan timeout

      log('Response status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Berhasil diupdate
        print('Transaksi berhasil diupdate');
        // Dispatch event atau update state di bloc/cubit jika diperlukan
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Data yang diberikan tidak valid';
        throw FormatException(errorMessage);
      } else if (response.statusCode == 404) {
        throw Exception('Transaksi tidak ditemukan');
      } else if (response.statusCode == 500) {
        throw Exception('Terjadi kesalahan di server');
      } else {
        // Tangani status code lainnya secara umum
        try {
          final responseBody = jsonDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Gagal mengupdate transaksi';
          throw Exception(
              'Gagal mengupdate transaksi: $errorMessage (Status Code: ${response.statusCode})');
        } catch (e) {
          throw Exception(
              'Gagal mengupdate transaksi: Status Code: ${response.statusCode}');
        }
      }
    } on FormatException catch (e) {
      rethrow;
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: $e');
    } on SocketException catch (e) {
      throw Exception('Tidak ada koneksi internet: $e');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final url = Endpoints.transactionDeleteUrl(id);
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        //perubahan disini untuk menangkap error
        throw Exception(
            'Gagal menghapus transaksi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat menghapus transaksi: $e');
    }
  }
}
