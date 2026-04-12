import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({required super.balance, required super.currency});

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'INR',
      );
}

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.description,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        id: json['id'] as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        type: json['type'] as String,
        description: json['description'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
