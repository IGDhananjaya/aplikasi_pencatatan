import 'package:aplikasi_pencatatan/endpoints/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import model dan TransactionCubit
import '../models/transaction.dart';
//import cubit
import '../cubit/transaction_cubit.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction
      transaction; // Parameter untuk data transaksi yang akan diedit
  const EditTransactionScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  DateTime? _selectedDate;
  String type = 'income';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Inisialisasi data dari transaksi yang akan diedit
  @override
  void initState() {
    super.initState();
    if (widget.transaction.date != null) {
      try {
        _selectedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.transaction.date!);
      } catch (e) {
        print('Error parsing date: $e');
        _selectedDate = DateTime.now();
      }
    }
    type = widget.transaction.type ?? 'income';
    _amountController.text = widget.transaction.amount.toString();
    _descriptionController.text = widget.transaction.description ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    // Sama seperti method _selectDate di AddTransactionScreen
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
    // Sama seperti method _resetForm di AddTransactionScreen
    setState(() {
      _selectedDate = null;
      type = 'income';
    });
    _amountController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              // Dropdown untuk type (sama seperti AddTransactionScreen)
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
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
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 1. Validasi Input
                  if (_selectedDate == null ||
                      _amountController.text.isEmpty ||
                      _descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pastikan Semua Data Terisi')),
                    );
                    return; // Hentikan proses jika validasi gagal
                  }

                  // 2. Konversi Tipe Data
                  final nim = Endpoints.nim.toString();
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  final description = _descriptionController.text;
                  final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!);
                  final id = int.parse(widget.transaction.id);

                  // 3. Panggil updateTransaction di Cubit
                  context.read<TransactionCubit>().updateTransaction(
                    id,
                    nim,
                    type,
                    amount,
                    description,
                    formattedDate,
                  );

                  // 4. Tutup Bottom Sheet
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
