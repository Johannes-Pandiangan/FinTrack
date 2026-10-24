import 'package:flutter/material.dart';

import '../core/constants/app_categories.dart';
import '../core/utils/app_clock.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

class DummyData {
  DummyData._();

  // Akun demo hanya untuk prototype frontend, bukan autentikasi sungguhan.
  static const String demoEmail = 'fintrack@email.com';
  static const String demoPassword = 'fintrack123';

  static const UserModel user = UserModel(
    id: 'u1',
    name: 'FinTrack',
    email: demoEmail,
    phone: '081234567890',
  );

  static const List<WalletModel> wallets = [
    WalletModel(
      id: 'w_cash',
      name: 'Tunai / Cash',
      type: WalletType.cash,
      balance: 1350000,
    ),
    WalletModel(
      id: 'w_bca',
      name: 'Bank BCA',
      type: WalletType.bank,
      balance: 18500000,
    ),
    WalletModel(
      id: 'w_gopay',
      name: 'GoPay E-Wallet',
      type: WalletType.ewallet,
      balance: 5000000,
    ),
  ];

  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'c_gaji',
      name: AppCategories.salary,
      icon: Icons.payments_rounded,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'c_bonus',
      name: AppCategories.bonus,
      icon: Icons.card_giftcard_rounded,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'c_investasi',
      name: AppCategories.investment,
      icon: Icons.trending_up_rounded,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'c_usaha',
      name: AppCategories.business,
      icon: Icons.storefront_rounded,
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'c_makanan',
      name: AppCategories.food,
      icon: Icons.restaurant_rounded,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'c_belanja',
      name: AppCategories.shopping,
      icon: Icons.shopping_bag_rounded,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'c_transportasi',
      name: AppCategories.transport,
      icon: Icons.directions_car_rounded,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'c_tagihan',
      name: AppCategories.bills,
      icon: Icons.receipt_long_rounded,
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'c_hiburan',
      name: AppCategories.entertainment,
      icon: Icons.movie_rounded,
      type: TransactionType.expense,
    ),
  ];

  static CategoryModel? categoryByName(String name) {
    for (final c in categories) {
      if (c.name == name) return c;
    }
    return null;
  }

  static TransactionModel _out(
    String id,
    String title,
    int amount,
    String category,
    String walletId,
    DateTime date, [
    String note = '',
  ]) {
    return TransactionModel(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.expense,
      category: category,
      walletId: walletId,
      date: date,
      note: note,
    );
  }

  static TransactionModel _in(
    String id,
    String title,
    int amount,
    String category,
    String walletId,
    DateTime date, [
    String note = '',
  ]) {
    return TransactionModel(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.income,
      category: category,
      walletId: walletId,
      date: date,
      note: note,
    );
  }

  /// Waktu relatif terhadap hari ini, supaya data contoh selalu terasa "baru"
  /// (bukan terkunci di tanggal tertentu). [daysAgo] = berapa hari yang lalu.
  static DateTime _at(int daysAgo, [int hour = 0, int minute = 0]) {
    final n = AppClock.today();
    return DateTime(n.year, n.month, n.day - daysAgo, hour, minute);
  }

  // Data contoh untuk prototype frontend. Akan digantikan data dari backend.
  static final List<TransactionModel> transactions = [
    _out('t1', 'Kopi Janji Jiwa', 28000, AppCategories.food, 'w_gopay',
        _at(0, 8, 30), 'Kopi pagi sebelum kuliah.'),
    _out(
        't2',
        'Restoran Padang Merdeka',
        125000,
        AppCategories.food,
        'w_cash',
        _at(0, 12, 15),
        'Makan siang bareng tim kantor cabang setelah review kuartal.'),
    _out('t3', 'Supermarket Indomaret', 185000, AppCategories.shopping,
        'w_cash', _at(0, 18, 40), 'Belanja kebutuhan bulanan.'),
    _out('t4', 'Tokopedia', 850000, AppCategories.shopping, 'w_gopay',
        _at(1, 20, 5), 'Belanja online.'),
    _out('t5', 'Shell V-Power', 200000, AppCategories.transport, 'w_cash',
        _at(1, 7, 50), 'Isi bahan bakar.'),
    _out('t6', 'Bakso Pak Slamet', 95000, AppCategories.food, 'w_cash',
        _at(3, 19, 10)),
    _in('t7', 'Gaji Bulanan', 15000000, AppCategories.salary, 'w_bca',
        _at(3, 9, 0), 'Gaji bulanan.'),
    _out('t8', 'Kuliner Akhir Pekan', 585000, AppCategories.food, 'w_bca',
        _at(4, 13, 0), 'Kumpul bareng teman.'),
    _out('t9', 'Konser Mini', 236000, AppCategories.entertainment, 'w_gopay',
        _at(6, 19, 30)),
    _out('t10', 'GrabFood', 145000, AppCategories.food, 'w_gopay',
        _at(7, 12, 40)),
    _out('t11', 'Servis Motor', 300000, AppCategories.transport, 'w_cash',
        _at(8, 10, 20), 'Servis rutin.'),
    _out('t12', 'Starbucks', 115000, AppCategories.food, 'w_gopay',
        _at(9, 15, 15)),
    _out('t13', 'Uniqlo', 400000, AppCategories.shopping, 'w_bca',
        _at(10, 16, 0)),
    _out('t14', 'Bioskop XXI', 150000, AppCategories.entertainment, 'w_gopay',
        _at(11, 18, 45)),
    _out('t15', 'Makan Malam Keluarga', 620000, AppCategories.food, 'w_bca',
        _at(12, 19, 30)),
    _out('t16', 'Gojek Langganan', 135000, AppCategories.transport, 'w_gopay',
        _at(13, 8, 0)),
    _out('t17', 'Alfamart', 152000, AppCategories.shopping, 'w_cash',
        _at(14, 17, 20)),
    _out('t18', 'Netflix', 186000, AppCategories.entertainment, 'w_bca',
        _at(15, 6, 0), 'Langganan bulanan.'),
    _in('t19', 'Transfer Klien', 3500000, AppCategories.business, 'w_bca',
        _at(16, 13, 20), 'Pembayaran proyek klien.'),
    _out('t20', 'Tagihan Air PDAM', 308000, AppCategories.bills, 'w_bca',
        _at(17, 9, 30)),
    _out('t21', 'Internet IndiHome', 385000, AppCategories.bills, 'w_bca',
        _at(18, 9, 10)),
    _out('t22', 'Listrik PLN', 450000, AppCategories.bills, 'w_bca',
        _at(19, 8, 45)),
    _out('t23', 'Katering Mingguan', 700000, AppCategories.food, 'w_bca',
        _at(21, 11, 0)),
    _in('t24', 'Dividen Reksadana', 450000, AppCategories.investment, 'w_bca',
        _at(24, 15, 45), 'Dividen reksadana kuartal ini.'),
  ];
}
