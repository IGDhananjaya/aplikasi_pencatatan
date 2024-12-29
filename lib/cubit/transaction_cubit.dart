import 'package:aplikasi_pencatatan/endpoints/endpoint.dart';
import 'package:aplikasi_pencatatan/models/saldo.dart';
import 'package:aplikasi_pencatatan/models/transaction.dart';
import 'package:aplikasi_pencatatan/repositories/transaction_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository transactionRepository;
  // Definisikan properti transactions dan saldo
  List<Transaction> transactions = [];
  Saldo? saldo;
  TransactionCubit({required this.transactionRepository})
      : super(TransactionInitial());

  Future<void> addTransaction(
    String nim, // Parameter NIM
    String type,
    double amount,
    String description,
    String date,
  ) async {
    print("Mengirim request ke repository:");
    print(
        "NIM: $nim, Type: $type, Amount: $amount, Description: $description, Date: $date");
    emit(TransactionLoading());
    try {
      await transactionRepository.addTransaction(
          nim, type, amount, description, date);
      emit(TransactionSuccess());
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  Future<void> reduceTransaction(
    String nim,
    String type, // Should be 'expense'
    double amount,
    String description,
    String date,
  ) async {
    print("Mengirim request ke repository:");
    print(
        "NIM: $nim, Type: $type, Amount: $amount, Description: $description, Date: $date");
    emit(TransactionLoading());
    try {
      await transactionRepository.reduceTransaction(
          nim, type, amount, description, date);
      print("reduceTransaction dipanggil dengan:");
      print(
          "NIM: $nim, Type: $type, Amount: $amount, Description: $description, Date: $date");
      emit(TransactionSuccess());
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  // Future<void> loadTransactions() async {
  //   emit(TransactionLoading());
  //   try {
  //     final transactions = await transactionRepository.getTransactions();
  //     emit(TransactionSuccess(transactions: transactions));
  //   } catch (e) {
  //     emit(TransactionFailure(e.toString()));
  //   }
  // }

  Future<void> loadTransactions() async {
    emit(TransactionLoading());
    try {
      transactions = await transactionRepository.getTransactions();
      if (transactions.isNotEmpty) {
        saldo = await transactionRepository.getSaldo(transactions[0].nim);
      }
      emit(TransactionSuccess(transactions: transactions, saldo: saldo));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  // Future<void> updateTransactionData(Transaction transaction) async {
  //   emit(TransactionLoading()); // Gunakan TransactionLoading untuk update
  //   try {
  //     await transactionRepository.updateTransaction(transaction);
  //     loadTransactions(); // Refresh data setelah update
  //   } catch (e) {
  //     emit(TransactionFailure(e.toString()));
  //   }
  // }

  // Future<void> deleteTransactionData(int id) async {
  //   emit(TransactionLoading()); // Gunakan TransactionLoading untuk delete
  //   try {
  //     await transactionRepository.deleteTransaction(id);
  //     loadTransactions(); // Refresh data setelah delete
  //   } catch (e) {
  //     emit(TransactionFailure(e.toString()));
  //   }
  // }

  Future<void> deleteTransactionData(int id) async {
    emit(TransactionLoading());
    try {
      await transactionRepository.deleteTransaction(id);
      loadTransactions();
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  Future<void> updateTransaction(int id, String nim, String type, double amount,
      String description, String date) async {
    emit(TransactionLoading());
    try {
      await transactionRepository.updateTransaction(
          id, nim, type, amount, description, date);
      await loadTransactions(); // Muat ulang data setelah update
      emit(TransactionSuccess(transactions: transactions, saldo: saldo));
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }
}
