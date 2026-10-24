import 'package:flutter/material.dart';

import '../../models/report_model.dart';
import '../../models/transaction_model.dart';
import 'formatters.dart';

/// Menghitung data laporan dari daftar transaksi.
class ReportBuilder {
  ReportBuilder._();

  static const List<String> _dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
  static const List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Rentang waktu; tanggal akhir bersifat eksklusif.
  static DateTimeRange range(ReportPeriod period, DateTime anchor) {
    switch (period) {
      case ReportPeriod.weekly:
        final start = DateTime(
          anchor.year,
          anchor.month,
          anchor.day - (anchor.weekday - 1),
        );
        return DateTimeRange(
          start: start,
          end: DateTime(start.year, start.month, start.day + 7),
        );
      case ReportPeriod.monthly:
        return DateTimeRange(
          start: DateTime(anchor.year, anchor.month, 1),
          end: DateTime(anchor.year, anchor.month + 1, 1),
        );
      case ReportPeriod.yearly:
        return DateTimeRange(
          start: DateTime(anchor.year, 1, 1),
          end: DateTime(anchor.year + 1, 1, 1),
        );
    }
  }

  static String label(ReportPeriod period, DateTime anchor) {
    final r = range(period, anchor);
    switch (period) {
      case ReportPeriod.weekly:
        final last = DateTime(r.end.year, r.end.month, r.end.day - 1);
        return '${Formatters.shortDate(r.start)} - ${Formatters.shortDate(last)}';
      case ReportPeriod.monthly:
        return Formatters.monthYear(anchor);
      case ReportPeriod.yearly:
        return '${anchor.year}';
    }
  }

  static DateTime shift(ReportPeriod period, DateTime anchor, int direction) {
    switch (period) {
      case ReportPeriod.weekly:
        return DateTime(anchor.year, anchor.month, anchor.day + 7 * direction);
      case ReportPeriod.monthly:
        return DateTime(anchor.year, anchor.month + direction, 1);
      case ReportPeriod.yearly:
        return DateTime(anchor.year + direction, 1, 1);
    }
  }

  static ReportModel build(
    List<TransactionModel> all,
    ReportPeriod period,
    DateTime anchor,
  ) {
    final r = range(period, anchor);
    final inRange = all
        .where((t) => !t.date.isBefore(r.start) && t.date.isBefore(r.end))
        .toList();

    late final List<String> labels;
    late final int Function(DateTime) indexOf;
    switch (period) {
      case ReportPeriod.weekly:
        labels = _dayLabels;
        indexOf = (d) => d.weekday - 1;
        break;
      case ReportPeriod.monthly:
        labels = const ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'];
        indexOf = (d) => ((d.day - 1) ~/ 7).clamp(0, 3).toInt();
        break;
      case ReportPeriod.yearly:
        labels = _monthLabels;
        indexOf = (d) => d.month - 1;
        break;
    }

    final income = List<int>.filled(labels.length, 0);
    final expense = List<int>.filled(labels.length, 0);
    final byCategory = <String, int>{};
    var totalIncome = 0;
    var totalExpense = 0;

    for (final t in inRange) {
      final i = indexOf(t.date);
      if (t.isIncome) {
        income[i] += t.amount;
        totalIncome += t.amount;
      } else {
        expense[i] += t.amount;
        totalExpense += t.amount;
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }
    }

    return ReportModel(
      income: totalIncome,
      expense: totalExpense,
      expenseByCategory: byCategory,
      buckets: [
        for (var i = 0; i < labels.length; i++)
          ReportBucket(
            label: labels[i],
            income: income[i],
            expense: expense[i],
          ),
      ],
    );
  }
}
