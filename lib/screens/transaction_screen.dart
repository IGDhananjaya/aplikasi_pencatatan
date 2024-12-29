// import 'package:aplikasi_pencatatan/endpoints/endpoint.dart';
// import 'dart:convert';

import 'package:aplikasi_pencatatan/cubit/transaction_cubit.dart';
// import 'package:aplikasi_pencatatan/endpoints/endpoint.dart';
// import 'package:aplikasi_pencatatan/models/saldo.dart';
import 'package:aplikasi_pencatatan/models/transaction.dart';
// import 'package:aplikasi_pencatatan/repositories/transaction_repository.dart';
import 'package:aplikasi_pencatatan/screens/edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
// import 'package:intl/date_symbol_data_local.dart';
//http
// import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp.',
    decimalDigits: 0,
  );

  final inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().loadTransactions();
  }

  // Fungsi showEditTransaction di TransactionScreen
  void showEditTransaction(BuildContext context, Transaction transaction) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        // Gunakan BlocProvider.value
        value: context
            .read<TransactionCubit>(), // Ambil instance Cubit yang sudah ada
        child: EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: BlocConsumer<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading...')),
            );
          } else if (state is TransactionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          } else if (state is TransactionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data berhasil diupdate/dihapus')),
            );
          }
        },
        builder: (context, state) {
          final transactions = context.read<TransactionCubit>().transactions;
          final saldo = context.read<TransactionCubit>().saldo;
          final inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
          transactions.sort((a, b) {
            try {
              final dateA = inputFormat.parse(a.date);
              final dateB = inputFormat.parse(b.date);
              return dateB
                  .compareTo(dateA); // Urutan descending (terbaru ke terlama)
            } catch (e) {
              print("Error parsing date during sorting: $e");
              return 0; // Atau logika penanganan error lainnya
            }
          });
          final groupedTransactions = groupBy<Transaction, DateTime>(
            transactions,
            (transaction) {
              // Konversi String ke DateTime di sini
              try {
                final inputFormat = DateFormat(
                    'yyyy-MM-dd HH:mm:ss'); // Sesuaikan dengan format API
                return DateTime(
                    inputFormat.parse(transaction.date).year,
                    inputFormat.parse(transaction.date).month,
                    inputFormat.parse(transaction.date).day);
              } catch (e) {
                // Tangani jika format tanggal tidak valid
                print('Error parsing date: $e');
                return DateTime.now(); // Atau nilai default lain, misalnya null
              }
            },
          );

          if (state is TransactionLoading && transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TransactionCubit>().loadTransactions(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (transactions.isEmpty) {
            return const Center(child: Text('Tidak ada data transaksi.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionCubit>().loadTransactions();
            },
            child: ListView(
              // Mengganti Column dengan ListView untuk RefreshIndicator bekerja dengan baik
              children: [
                if (saldo != null)
                  Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Saldo anda:',
                                  style: TextStyle(fontSize: 18)),
                              Text(
                                formatCurrency.format(saldo.saldo),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const Divider(),
                // Menggunakan map untuk iterasi data yang sudah dikelompokkan
                ...groupedTransactions.entries.map((entry) {
                  final date = entry.key;
                  final transactionsForDate = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          DateFormat.yMMMMd('id_ID')
                              .format(date), // Format tanggal Indonesia
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactionsForDate.length,
                        itemBuilder: (context, innerIndex) {
                          final transaction = transactionsForDate[innerIndex];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: ListTile(
                              leading: Text('${innerIndex + 1}.'), // Nomor urut
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    // Row untuk ikon dan tipe
                                    children: [
                                      if (transaction.type ==
                                          'income') // Cek tipe transaksi
                                        const Icon(Icons.arrow_upward,
                                            color: Colors.green), // Ikon income
                                      if (transaction.type == 'expense')
                                        const Icon(Icons.arrow_downward,
                                            color: Colors.red), // Ikon expense
                                      const SizedBox(
                                          width:
                                              8), // Spasi antara ikon dan teks
                                      Text(transaction.type), // Tipe transaksi
                                    ],
                                  ),
                                  Text(
                                    transaction
                                        .description, // Deskripsi transaksi
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Rp ${formatCurrency.format(transaction.amount)} at ${DateFormat('HH:mm:ss').format(inputFormat.parse(transaction.date))}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    // Tombol Edit
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            child: BlocProvider.value(
                                              value: context
                                                  .read<TransactionCubit>(),
                                              child: EditTransactionScreen(
                                                  transaction: transaction),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    // Tombol Delete
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text("Konfirmasi Hapus"),
                                            content: const Text(
                                                "Apakah Anda yakin ingin menghapus transaksi ini?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Batal"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  context
                                                      .read<TransactionCubit>()
                                                      .deleteTransactionData(
                                                          int.parse(
                                                              transaction.id));
                                                },
                                                child: const Text("Hapus"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
