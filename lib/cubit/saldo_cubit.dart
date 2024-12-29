import 'package:bloc/bloc.dart';
import '../models/saldo.dart';
import '../repositories/transaction_repository.dart'; // Assuming TransactionRepository is renamed

enum SaldoStatus { initial, loading, success, failure }

class SaldoState {
  final SaldoStatus status;
  final Saldo? saldo;
  final String? errorMessage;

  SaldoState({
    this.status = SaldoStatus.initial,
    this.saldo,
    this.errorMessage,
  });

  SaldoState copyWith({
    SaldoStatus? status,
    Saldo? saldo,
    String? errorMessage,
  }) {
    return SaldoState(
      status: status ?? this.status,
      saldo: saldo ?? this.saldo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SaldoCubit extends Cubit<SaldoState> {
  final TransactionRepository transactionRepository;

  SaldoCubit({required this.transactionRepository})
      : super(SaldoState());

  Future<void> loadSaldo(String nim) async {
    try {
      emit(state.copyWith(status: SaldoStatus.loading));
      final saldo = await transactionRepository.getSaldo(nim);
      emit(state.copyWith(status: SaldoStatus.success, saldo: saldo));
    } catch (e) {
      emit(state.copyWith(status: SaldoStatus.failure, errorMessage: e.toString()));
    }
  }
}