import 'package:flutter/material.dart';

enum WalletType { cash, bank, ewallet }

extension WalletTypeX on WalletType {
  String get label {
    switch (this) {
      case WalletType.cash:
        return 'Cash';
      case WalletType.bank:
        return 'Bank';
      case WalletType.ewallet:
        return 'E-Wallet';
    }
  }

  IconData get icon {
    switch (this) {
      case WalletType.cash:
        return Icons.payments_rounded;
      case WalletType.bank:
        return Icons.account_balance_rounded;
      case WalletType.ewallet:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

class WalletModel {
  final String id;
  final String name;
  final WalletType type;
  final int balance;

  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  WalletModel copyWith({String? name, WalletType? type, int? balance}) {
    return WalletModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'balance': balance,
      };

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: WalletType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => WalletType.cash,
      ),
      balance: (json['balance'] as num).toInt(),
    );
  }
}
