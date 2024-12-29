import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aplikasi_pencatatan/cubit/saldo_cubit.dart';
import 'package:aplikasi_pencatatan/endpoints/endpoint.dart';
import 'package:aplikasi_pencatatan/repositories/transaction_repository.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nim = Endpoints.nim;
    final transactionRepository = TransactionRepository();

    return BlocProvider.value(
      // Menggunakan BlocProvider.value
      value:
          BlocProvider.of<SaldoCubit>(context), // Ambil instance yang sudah ada
      child: _HomeScreenContent(nim: nim), // Kirim NIM ke _HomeScreenContent
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final String nim;
  const _HomeScreenContent({Key? key, required this.nim}) : super(key: key);

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaldoCubit>().loadSaldo(widget.nim);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      body: BlocConsumer<SaldoCubit, SaldoState>(
        listener: (context, state) {
          if (state.status == SaldoStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SaldoStatus.success && state.saldo != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Berikut adalah saldo Anda:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          formatCurrency.format(state.saldo!.saldo),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Current Balance")
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state.status == SaldoStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Tidak ada data saldo.'));
          }
        },
      ),
    );
  }
}
