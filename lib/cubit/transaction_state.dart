//merupakan bagian dari transaction_cubit
part of 'transaction_cubit.dart';

// import 'package:equatable/equatable.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final List<Transaction>? transactions; // Tambahkan properti transactions
  final Saldo? saldo;

  const TransactionSuccess({this.transactions, this.saldo});

  @override
  List<Object> get props =>
      super.props +
      [
        transactions ?? [],
        saldo ?? ''
      ]; // Tambahkan transactions dan saldo ke props
}

// class TransactionFailure extends TransactionState {
//   final String error;

//   const TransactionFailure(this.error);

//   @override
//   List<Object> get props => [error];
// }

class TransactionFailure extends TransactionState {
  final String error;

  const TransactionFailure(this.error);

  @override
  List<Object> get props => [error];
}
