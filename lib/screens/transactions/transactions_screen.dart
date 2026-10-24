import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_clock.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/report_builder.dart';
import '../../data/dummy_data.dart';
import '../../models/report_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/category_chip/app_filter_chip.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/fade_in.dart';
import '../../widgets/common/period_selector.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/transaction_card/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime _month = AppClock.today();
  DateTimeRange? _custom;
  String? _walletId;
  String? _category;

  DateTimeRange get _range {
    final c = _custom;
    if (c != null) {
      return DateTimeRange(
        start: DateTime(c.start.year, c.start.month, c.start.day),
        end: DateTime(c.end.year, c.end.month, c.end.day + 1),
      );
    }
    return ReportBuilder.range(ReportPeriod.monthly, _month);
  }

  String get _periodLabel {
    final c = _custom;
    if (c != null) {
      return '${Formatters.shortDate(c.start)} - ${Formatters.shortDate(c.end)}';
    }
    return Formatters.monthYear(_month);
  }

  void _shiftMonth(int dir) {
    setState(() {
      _custom = null;
      _month = DateTime(_month.year, _month.month + dir, 1);
    });
  }

  Future<void> _pickCustom() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _custom,
    );
    if (picked != null) setState(() => _custom = picked);
  }

  /// Kategori bawaan ditambah kategori manual yang sudah dipakai transaksi.
  List<String> _categoryNames(List<TransactionModel> all) {
    final names = DummyData.categories.map((c) => c.name).toList();
    for (final t in all) {
      if (!names.contains(t.category)) names.add(t.category);
    }
    return names;
  }

  List<TransactionModel> _filtered(List<TransactionModel> all) {
    final r = _range;
    return all.where((t) {
      if (t.date.isBefore(r.start) || !t.date.isBefore(r.end)) return false;
      if (_walletId != null && t.walletId != _walletId) return false;
      if (_category != null && t.category != _category) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = _filtered(state.transactions);

    var income = 0;
    var expense = 0;
    for (final t in items) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final net = income - expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24 + AppConstants.fabClearance,
      ),
      child: FadeIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(showNotification: true),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Transaksi', style: AppTextStyles.h1),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: PeriodSelector(
                    label: _periodLabel,
                    onPrevious: () => _shiftMonth(-1),
                    onNext: () => _shiftMonth(1),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _pickCustom,
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: const Text('Custom'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _CashFlowSummary(
              income: income,
              expense: expense,
              net: net,
            ),
            const SizedBox(height: 18),
            Text('SUMBER DANA', style: AppTextStyles.overline),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  AppFilterChip(
                    label: 'Semua Dompet',
                    selected: _walletId == null,
                    onTap: () => setState(() => _walletId = null),
                  ),
                  for (final w in state.wallets) ...[
                    const SizedBox(width: 8),
                    AppFilterChip(
                      label: w.name,
                      selected: _walletId == w.id,
                      onTap: () => setState(() => _walletId = w.id),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('KATEGORI', style: AppTextStyles.overline),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  AppFilterChip(
                    label: 'Semua',
                    selected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  for (final name in _categoryNames(state.transactions)) ...[
                    const SizedBox(width: 8),
                    AppFilterChip(
                      label: name,
                      selected: _category == name,
                      onTap: () => setState(() => _category = name),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (items.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'Belum Ada Transaksi',
                message: 'Mulai catat pemasukan atau pengeluaranmu.',
                buttonLabel: 'Catat Transaksi',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.addTransaction),
              )
            else
              ..._buildGroups(context, state, items),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroups(
    BuildContext context,
    AppState state,
    List<TransactionModel> items,
  ) {
    final groups = <DateTime, List<TransactionModel>>{};
    for (final t in items) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(key, () => []).add(t);
    }

    final today = AppClock.today();
    final todayKey = DateTime(today.year, today.month, today.day);
    final yesterdayKey = DateTime(today.year, today.month, today.day - 1);

    final widgets = <Widget>[];
    groups.forEach((day, list) {
      final String title;
      final String? subtitle;
      if (day == todayKey) {
        title = 'Hari Ini';
        subtitle = Formatters.shortDate(day);
      } else if (day == yesterdayKey) {
        title = 'Kemarin';
        subtitle = Formatters.shortDate(day);
      } else {
        title = Formatters.longDate(day);
        subtitle = null;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(title, style: AppTextStyles.h3),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
      );
      for (final t in list) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TransactionCard(
              transaction: t,
              walletName: state.walletById(t.walletId)?.name ?? '-',
              onTap: () => AppRoutes.openTransaction(context, t.id),
            ),
          ),
        );
      }
    });
    return widgets;
  }
}

class _CashFlowSummary extends StatelessWidget {
  final int income;
  final int expense;
  final int net;

  const _CashFlowSummary({
    required this.income,
    required this.expense,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final surplus = net >= 0;
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primaryLight, AppColors.primaryDark],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ARUS KAS PERIODE',
                  style: AppTextStyles.overline.copyWith(
                    color: const Color(0xCCFFFFFF),
                  ),
                ),
              ),
              StatusBadge(
                label: surplus ? 'Surplus' : 'Defisit',
                icon: surplus
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: surplus ? AppColors.income : AppColors.expense,
                background: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stat(
                  label: 'Pemasukan',
                  value: Formatters.rupiahCompact(income, withSign: true),
                  color: AppColors.incomeOnDark,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Pengeluaran',
                  value: Formatters.rupiahCompact(-expense),
                  color: AppColors.expenseOnDark,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Selisih Bersih',
                  value: Formatters.rupiahCompact(net, withSign: true),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
