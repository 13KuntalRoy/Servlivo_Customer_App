import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/get_wallet_usecase.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletBalanceUseCase _getBalance;
  final GetWalletTransactionsUseCase _getTransactions;

  WalletCubit({
    required GetWalletBalanceUseCase getBalance,
    required GetWalletTransactionsUseCase getTransactions,
  })  : _getBalance = getBalance,
        _getTransactions = getTransactions,
        super(const WalletInitial());

  Future<void> load() async {
    emit(const WalletLoading());
    final balanceResult = await _getBalance();
    balanceResult.fold(
      (failure) => emit(WalletError(failure.message)),
      (balance) async {
        final txResult = await _getTransactions();
        txResult.fold(
          (failure) => emit(WalletError(failure.message)),
          (transactions) => emit(WalletLoaded(balance: balance, transactions: transactions)),
        );
      },
    );
  }
}
