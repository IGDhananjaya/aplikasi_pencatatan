import 'package:aplikasi_pencatatan/cubit/saldo_cubit.dart';
import 'package:aplikasi_pencatatan/cubit/transaction_cubit.dart';
import 'package:aplikasi_pencatatan/repositories/transaction_repository.dart';
import 'package:aplikasi_pencatatan/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart'; // Import intl
import 'package:intl/date_symbol_data_local.dart'; // Import date_symbol_data_local

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan ini diinisialisasi pertama

  try {
    await initializeDateFormatting('id_ID', null); // Inisialisasi locale Indonesia
    print('Locale id_ID initialized successfully');
  } catch (e) {
    print('Error initializing locale: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionRepository = TransactionRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<SaldoCubit>(
          create: (context) => SaldoCubit(transactionRepository: transactionRepository),
        ),
        BlocProvider<TransactionCubit>(
          create: (context) => TransactionCubit(transactionRepository: transactionRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Aplikasi Pencatatan',
        debugShowCheckedModeBanner: false,
        home: const PersistentBottomBar(),
      ),
    );
  }
}