import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final double balance;
  final String currency;

  const WalletEntity({required this.balance, required this.currency});

  @override
  List<Object> get props => [balance, currency];
}

class WalletTransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String type; // credit, debit
  final String description;
  final DateTime createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, amount, type];
}
