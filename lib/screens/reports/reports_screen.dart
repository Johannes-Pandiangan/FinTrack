import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_clock.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/finai_engine.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/report_builder.dart';
import '../../models/report_model.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/charts/cash_flow_chart.dart';
import '../../widgets/charts/expense_distribution.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/period_selector.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/sheets/budget_simulator_sheet.dart';
import '../../widgets/summary_card/income_expense_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.monthly;
  DateTime _anchor = AppClock.today();
  bool _insightVisible = true;

  static const Map<ReportPeriod, String> _tabLabels = {
    ReportPeriod.weekly: 'Mingguan',
    ReportPeriod.monthly: 'Bulanan',
    ReportPeriod.yearly: 'Tahunan',
  };

  String get _chartTitle {
    switch (_period) {
      case ReportPeriod.weekly:
        return 'Arus Kas Harian';
      case ReportPeriod.monthly:
        return 'Arus Kas Mingguan';
      case ReportPeriod.yearly:
        return 'Arus Kas Bulanan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final report = ReportBuilder.build(state.transactions, _period, _anchor);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(
                showBack: true,
                menu: PopupMenuButton<String>(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (_) =>
                      Navigator.pushNamed(context, AppRoutes.export),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'export', child: Text('Unduh Laporan')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                children: [
                  Text('Laporan', style: AppTextStyles.h1),
                  const SizedBox(height: 14),
                  _PeriodTabs(
                    selected: _period,
                    labels: _tabLabels,
                    onChanged: (p) => setState(() {
                      _period = p;
                      _anchor = AppClock.today();
                    }),
                  ),
                  const SizedBox(height: 12),
                  PeriodSelector(
                    label: ReportBuilder.label(_period, _anchor),
                    onPrevious: () => setState(
                      () => _anchor = ReportBuilder.shift(_period, _anchor, -1),
                    ),
                    onNext: () => setState(
                      () => _anchor = ReportBuilder.shift(_period, _anchor, 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (report.isEmpty)
                    EmptyState(
                      icon: Icons.insert_chart_outlined_rounded,
                      title: 'Belum cukup data',
                      message:
                          'Tambahkan beberapa transaksi untuk melihat laporan.',
                      buttonLabel: 'Catat Transaksi',
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.addTransaction),
                    )
                  else
                    ..._content(context, report),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, ReportModel report) {
    return [
      AppCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primaryDark],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SURPLUS BERSIH KAS',
              style: AppTextStyles.overline
                  .copyWith(color: const Color(0xCCFFFFFF)),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.rupiah(report.net),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: IncomeExpenseCard(
              label: 'Pengeluaran',
              amount: report.expense,
              icon: Icons.arrow_upward_rounded,
              color: AppColors.expense,
              background: AppColors.expenseSoft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: IncomeExpenseCard(
              label: 'Pemasukan',
              amount: report.income,
              icon: Icons.arrow_downward_rounded,
              color: AppColors.income,
              background: AppColors.incomeSoft,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_chartTitle, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            const ChartLegend(),
            const SizedBox(height: 16),
            CashFlowChart(buckets: report.buckets),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribusi Pengeluaran', style: AppTextStyles.h3),
            const SizedBox(height: 14),
            ExpenseDistribution(totals: report.expenseByCategory),
          ],
        ),
      ),
      if (_insightVisible) ...[
        const SizedBox(height: 14),
        AppCard(
          color: AppColors.yellowSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: AppColors.yellow),
                  const SizedBox(width: 8),
                  Text(
                    'FinAI Smart Insight',
                    style:
                        AppTextStyles.label.copyWith(color: AppColors.yellow),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                FinAIEngine.weekendInsight(
                  context.read<AppState>().transactions,
                  _period,
                  _anchor,
                ),
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Simulasi Anggaran',
                onPressed: () => showBudgetSimulator(context, report),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Abaikan',
                color: AppColors.textSecondary,
                onPressed: () => setState(() => _insightVisible = false),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 20),
      SecondaryButton(
        label: 'Unduh Laporan PDF / Excel',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.export),
      ),
      const SizedBox(height: 12),
    ];
  }
}

class _PeriodTabs extends StatelessWidget {
  final ReportPeriod selected;
  final Map<ReportPeriod, String> labels;
  final ValueChanged<ReportPeriod> onChanged;

  const _PeriodTabs({
    required this.selected,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (final e in labels.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: selected == e.key,
                label: e.value,
                child: GestureDetector(
                  onTap: () => onChanged(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected == e.key
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected == e.key
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
