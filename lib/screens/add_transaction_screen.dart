import 'package:aplikasi_pencatatan/cubit/saldo_cubit.dart';
import 'package:aplikasi_pencatatan/cubit/transaction_cubit.dart';
import 'package:aplikasi_pencatatan/endpoints/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// ... import lainnya

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  DateTime? _selectedDate;
  String type = 'income';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedDate = null;
      type = 'income';
    });
    _amountController.clear();
    _descriptionController.clear();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nim = Endpoints.nim.toString();
    return Scaffold(
      // appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: BlocConsumer<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            _resetForm(); // Reset form input
            BlocProvider.of<SaldoCubit>(context).loadSaldo(nim);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi Berhasil Ditambahkan')),
            );
          } else if (state is TransactionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(
                          value: 'income', child: Text('Pemasukan')),
                      DropdownMenuItem(
                          value: 'expense', child: Text('Pengeluaran')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        type = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Jenis'),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(_selectedDate == null
                            ? 'No date chosen!'
                            : 'Tanggal dipilih: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Pilih Tanggal'),
                      ),
                    ],
                  ),
                  // TextFormField(
                  //   controller: _amountController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: const InputDecoration(labelText: 'Jumlah'),
                  // ),
                  TextFormField(
                    // Contoh TextFormField dengan validasi
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah harus diisi';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Jumlah harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  // TextFormField(
                  //   controller: _descriptionController,
                  //   decoration: const InputDecoration(labelText: 'Deskripsi'),
                  // ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi harus diisi';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: state is TransactionLoading
                        ? null
                        : () {
                            if (_selectedDate == null ||
                                _amountController.text.isEmpty ||
                                _descriptionController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Pastikan Semua Data Terisi')),
                              );
                              return;
                            }
                            final amount =
                                double.tryParse(_amountController.text) ?? 0;
                            final description = _descriptionController.text;
                            final formattedDate =
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(_selectedDate!);
                            if (type == 'income') {
                              context.read<TransactionCubit>().addTransaction(
                                    nim,
                                    type,
                                    amount,
                                    description,
                                    formattedDate,
                                  );
                            } else if (type == 'expense') {
                              context
                                  .read<TransactionCubit>()
                                  .reduceTransaction(
                                    nim,
                                    type,
                                    amount,
                                    description,
                                    formattedDate,
                                  );
                            }
                          },
                    child: state is TransactionLoading
                        ? const CircularProgressIndicator()
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
