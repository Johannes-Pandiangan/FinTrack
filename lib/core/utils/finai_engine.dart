import '../constants/app_categories.dart';
import '../../models/report_model.dart';
import '../../models/transaction_model.dart';
import 'formatters.dart';
import 'report_builder.dart';

/// "Otak" FinAI berbasis aturan yang membaca data transaksi asli.
/// Ini bukan model AI; jawabannya dihitung dari data di aplikasi.
class FinAIEngine {
  FinAIEngine._();

  static const String food = AppCategories.food;
  static const List<String> _discretionary = AppCategories.discretionary;

  static ReportModel monthReport(List<TransactionModel> txs, DateTime anchor) =>
      ReportBuilder.build(txs, ReportPeriod.monthly, anchor);

  static int shoppingRatio(ReportModel r) {
    if (r.expense == 0) return 0;
    return ((r.expenseByCategory[AppCategories.shopping] ?? 0) *
            100 /
            r.expense)
        .round();
  }

  /// Perkiraan simpanan jika pengeluaran tidak wajib dipangkas 15%.
  static int savingPotential(ReportModel r) {
    var total = 0;
    for (final c in _discretionary) {
      total += r.expenseByCategory[c] ?? 0;
    }
    return (total * 0.15).round();
  }

  static String weeklyInsight(List<TransactionModel> txs, DateTime today) {
    final elapsed = today.weekday;
    final weekStart =
        DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final prevStart =
        DateTime(weekStart.year, weekStart.month, weekStart.day - 7);
    final prevEnd =
        DateTime(prevStart.year, prevStart.month, prevStart.day + elapsed);
    final end = DateTime(today.year, today.month, today.day + 1);

    int sum(DateTime a, DateTime b) => txs
        .where(
          (t) =>
              !t.isIncome &&
              t.category == food &&
              !t.date.isBefore(a) &&
              t.date.isBefore(b),
        )
        .fold<int>(0, (s, t) => s + t.amount);

    final thisWeek = sum(weekStart, end);
    final prevWeek = sum(prevStart, prevEnd);

    if (prevWeek == 0) {
      return thisWeek == 0
          ? 'Belum ada pengeluaran makan di luar minggu ini.'
          : 'Pengeluaran makan di luar minggu ini ${Formatters.rupiah(thisWeek)}.';
    }
    final pct = ((thisWeek - prevWeek) * 100 / prevWeek).round();
    if (pct == 0) {
      return 'Pengeluaran makan di luar sama dengan minggu lalu.';
    }
    return pct < 0
        ? 'Pengeluaran makan di luar turun ${-pct}% dibanding minggu lalu!'
        : 'Pengeluaran makan di luar naik $pct% dibanding minggu lalu.';
  }

  static String weekendInsight(
    List<TransactionModel> txs,
    ReportPeriod period,
    DateTime anchor,
  ) {
    final r = ReportBuilder.range(period, anchor);
    final foodTx = txs
        .where(
          (t) =>
              !t.isIncome &&
              t.category == food &&
              !t.date.isBefore(r.start) &&
              t.date.isBefore(r.end),
        )
        .toList();
    final total = foodTx.fold<int>(0, (s, t) => s + t.amount);
    if (total == 0) return 'Belum ada pengeluaran kuliner pada periode ini.';
    final weekend = foodTx
        .where((t) => t.date.weekday >= 6)
        .fold<int>(0, (s, t) => s + t.amount);
    final pct = (weekend * 100 / total).round();
    return 'Pengeluaran kuliner akhir pekan mencapai $pct% (${Formatters.rupiah(weekend)}) dari total makanan & minuman periode ini.';
  }

  /// Membaca nominal dari teks, mis. "150rb", "2,5 jt", "12.000.000".
  static int? parseAmount(String text) {
    final m = RegExp(
      r'(\d+(?:[.,]\d+)*)\s*(rb|ribu|k|jt|juta)?',
      caseSensitive: false,
    ).firstMatch(text.toLowerCase());
    if (m == null) return null;

    var digits = m.group(1)!;
    if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(digits)) {
      digits = digits.replaceAll('.', '');
    } else {
      digits = digits.replaceAll(',', '.');
    }
    final value = double.tryParse(digits);
    if (value == null) return null;

    final unit = m.group(2);
    var multiplier = 1;
    if (unit == 'rb' || unit == 'ribu' || unit == 'k') multiplier = 1000;
    if (unit == 'jt' || unit == 'juta') multiplier = 1000000;
    if (unit == null && value < 1000) return null;

    final result = (value * multiplier).round();
    return result > 0 ? result : null;
  }

  static String reply({
    required String question,
    required List<TransactionModel> txs,
    required DateTime anchor,
    required int totalBalance,
  }) {
    final q = question.toLowerCase();
    final r = monthReport(txs, anchor);
    final month = Formatters.monthYear(anchor);

    if (r.isEmpty) {
      return 'Belum ada transaksi pada $month. Catat beberapa transaksi dulu agar saya bisa menganalisis.';
    }

    if (q.contains('laptop') || q.contains('cicil') || q.contains('beli')) {
      final price = parseAmount(q);
      final monthlySave = (r.net * 0.5).round();
      if (r.net <= 0) {
        return 'Bulan ini pengeluaranmu melebihi pemasukan, jadi belum aman untuk pembelian besar. Kurangi pengeluaran dulu.';
      }
      if (price == null) {
        return 'Surplus $month ${Formatters.rupiah(r.net)}. Jika kamu menyisihkan 50% (${Formatters.rupiah(monthlySave)}) per bulan, kamu bisa menabung ${Formatters.rupiah(monthlySave * 3)} dalam 3 bulan. Sebutkan harga targetnya untuk hitungan yang lebih tepat.';
      }
      final months = (price / monthlySave).ceil();
      final affordable = price <= totalBalance;
      return 'Target ${Formatters.rupiah(price)}: dengan menyisihkan ${Formatters.rupiah(monthlySave)} per bulan, tercapai sekitar $months bulan. ${affordable ? 'Total saldomu saat ini sudah cukup, tetapi sebaiknya tetap sisakan dana darurat.' : 'Saldomu saat ini belum mencukupi.'}';
    }

    if (q.contains('belanja')) {
      final entries = r.expenseByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = entries
          .take(3)
          .map((e) => '${e.key} ${Formatters.rupiah(e.value)}')
          .join(', ');
      return 'Belanja menyumbang ${shoppingRatio(r)}% dari pengeluaran $month. Tiga pengeluaran terbesar: $top.';
    }

    if (q.contains('hemat') || q.contains('kurangi')) {
      String? topName;
      var topValue = 0;
      for (final c in _discretionary) {
        final v = r.expenseByCategory[c] ?? 0;
        if (v > topValue) {
          topValue = v;
          topName = c;
        }
      }
      if (topName == null) {
        return 'Pengeluaranmu bulan ini sudah ringan. Pertahankan!';
      }
      return 'Kategori tidak wajib terbesar adalah $topName (${Formatters.rupiah(topValue)}). Memangkas pengeluaran tidak wajib 15% berpotensi menghemat sekitar ${Formatters.rupiah(savingPotential(r))} per bulan.';
    }

    if (q.contains('nabung') || q.contains('tabungan')) {
      final target = (r.income * 0.2).round();
      return 'Pemasukan $month ${Formatters.rupiah(r.income)}. Sisihkan 20% (${Formatters.rupiah(target)}) tepat setelah menerima pemasukan.';
    }

    if (q.contains('kopi')) {
      final coffee = txs.where((t) {
        final title = t.title.toLowerCase();
        return !t.isIncome &&
            (title.contains('kopi') ||
                title.contains('starbucks') ||
                title.contains('coffee'));
      });
      final total = coffee.fold<int>(0, (s, t) => s + t.amount);
      final count = coffee.length;
      if (count == 0) return 'Belum ada transaksi kopi yang tercatat.';
      return 'Tercatat $count transaksi kopi senilai ${Formatters.rupiah(total)}. Membuat kopi sendiri beberapa kali seminggu bisa memangkas pengeluaran ini.';
    }

    if (q.contains('saldo')) {
      return 'Total saldo semua dompetmu saat ini ${Formatters.rupiah(totalBalance)}.';
    }

    if (q.contains('ringkas') ||
        q.contains('laporan') ||
        q.contains('analisis') ||
        q.contains('pengeluaran') ||
        q.contains('pemasukan')) {
      return 'Ringkasan $month: pemasukan ${Formatters.rupiah(r.income)}, pengeluaran ${Formatters.rupiah(r.expense)}, surplus ${Formatters.rupiah(r.net)}.';
    }

    return 'Saya bisa membantu dengan: analisis belanja, saran penghematan, cara menabung, simulasi membeli barang (mis. "laptop 12 juta"), tips kopi, cek saldo, ringkasan bulanan, dan memasang batas harian (mis. "batas harian 150rb").';
  }
}
