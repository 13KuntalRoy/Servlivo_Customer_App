part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentProcessing extends PaymentState {
  final PaymentOrderEntity order;
  const PaymentProcessing(this.order);

  @override
  List<Object> get props => [order];
}

class PaymentCompleted extends PaymentState {
  final PaymentEntity payment;
  const PaymentCompleted(this.payment);

  @override
  List<Object> get props => [payment];
}

class TransactionsState extends PaymentState {
  final List<PaymentEntity> transactions;
  const TransactionsState(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
