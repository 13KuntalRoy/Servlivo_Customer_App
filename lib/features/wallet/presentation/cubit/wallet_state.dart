part of 'wallet_cubit.dart';

sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final WalletEntity balance;
  final List<WalletTransactionEntity> transactions;

  const WalletLoaded({required this.balance, required this.transactions});

  @override
  List<Object> get props => [balance, transactions];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);

  @override
  List<Object> get props => [message];
}
