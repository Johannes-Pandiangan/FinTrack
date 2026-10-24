import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_clock.dart';
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
import '../../widgets/common/fade_in.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/sheets/daily_limit_dialog.dart';
import '../../widgets/summary_card/balance_card.dart';
import '../../widgets/summary_card/income_expense_card.dart';
import '../../widgets/transaction_card/transaction_card.dart';
import '../../widgets/wallet_card/wallet_card.dart';

/// Dashboard / Beranda.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final today = AppClock.today();
    final report = ReportBuilder.build(
      state.transactions,
      ReportPeriod.monthly,
      today,
    );
    final recents = state.transactions.take(5).toList();
    final wallets = state.wallets;

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
            const AppHeader(
              showNotification: true,
              overline: 'FINTRACK GREEN',
              title: 'Beranda',
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user?.name ?? 'Pengguna'} 👋',
                          style: AppTextStyles.h2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.fullDate(today),
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BalanceCard(
              balance: state.totalBalance,
              income: report.income,
              expense: report.expense,
            ),
            if (state.reminderEnabled &&
                AppClock.now().hour >= 20 &&
                !state.hasTransactionOn(AppClock.today())) ...[
              const SizedBox(height: 16),
              _ReminderBanner(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.addTransaction),
              ),
            ],
            if (state.dailyLimit != null) ...[
              const SizedBox(height: 16),
              _DailyLimitCard(
                limit: state.dailyLimit!,
                spent: state.expenseOn(today),
                onTap: () => showDailyLimitDialog(context),
              ),
            ],
            const SizedBox(height: 16),
            _FinAiCard(
              message: FinAIEngine.weeklyInsight(state.transactions, today),
              onAsk: () => state.setTab(2),
            ),
            const SizedBox(height: 16),
            _ReportCard(
              report: report,
              monthLabel: Formatters.monthYear(today),
              insight: FinAIEngine.weekendInsight(
                state.transactions,
                ReportPeriod.monthly,
                today,
              ),
              onOpen: () => Navigator.pushNamed(context, AppRoutes.reports),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Dompet & Rekening',
              actionLabel: 'Kelola Dompet →',
              onAction: () => Navigator.pushNamed(context, AppRoutes.wallets),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 124,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: wallets.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  if (i == wallets.length) {
                    return WalletCard(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.wallets),
                    );
                  }
                  return WalletCard(
                    wallet: wallets[i],
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.wallets),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Transaksi Terkini',
              actionLabel: 'Lihat Semua',
              onAction: () => state.setTab(1),
            ),
            const SizedBox(height: 8),
            if (recents.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'Belum Ada Transaksi',
                message: 'Mulai catat pemasukan atau pengeluaranmu.',
                buttonLabel: 'Catat Transaksi',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.addTransaction),
              )
            else
              for (final t in recents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TransactionCard(
                    transaction: t,
                    walletName: state.walletById(t.walletId)?.name ?? '-',
                    onTap: () => AppRoutes.openTransaction(context, t.id),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final String monthLabel;
  final String insight;
  final VoidCallback onOpen;

  const _ReportCard({
    required this.report,
    required this.monthLabel,
    required this.insight,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final surplus = report.net >= 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Laporan & Analisis', style: AppTextStyles.h3),
              ),
              Text(monthLabel, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 14),
          if (report.isEmpty)
            Text(
              'Belum ada transaksi bulan ini. Catat transaksi agar laporan dan analisis muncul di sini.',
              style: AppTextStyles.bodySecondary,
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: IncomeExpenseCard(
                    label: 'Pemasukan',
                    amount: report.income,
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.income,
                    background: AppColors.incomeSoft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IncomeExpenseCard(
                    label: 'Pengeluaran',
                    amount: report.expense,
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.expense,
                    background: AppColors.expenseSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    surplus ? 'Surplus bulan ini' : 'Defisit bulan ini',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
                Text(
                  Formatters.rupiah(report.net.abs()),
                  style: AppTextStyles.label.copyWith(
                    color: surplus ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            Text('Tren Arus Kas', style: AppTextStyles.label),
            const SizedBox(height: 4),
            const ChartLegend(),
            const SizedBox(height: 12),
            CashFlowChart(buckets: report.buckets, height: 110),
            const SizedBox(height: 18),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            Text('Distribusi Pengeluaran', style: AppTextStyles.label),
            const SizedBox(height: 12),
            ExpenseDistribution(totals: report.expenseByCategory),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.yellowSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: AppColors.yellow),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(insight, style: AppTextStyles.bodySecondary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SecondaryButton(label: 'Lihat Laporan Lengkap →', onPressed: onOpen),
        ],
      ),
    );
  }
}

class _FinAiCard extends StatelessWidget {
  final String message;
  final VoidCallback onAsk;

  const _FinAiCard({required this.message, required this.onAsk});

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                'REKOMENDASI FINAI',
                style: AppTextStyles.overline.copyWith(color: AppColors.yellow),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(message, style: AppTextStyles.h3),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Tanya FinAI →', onPressed: onAsk),
        ],
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ReminderBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.orangeSoft,
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.alarm_rounded, color: AppColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pengingat: belum ada transaksi tercatat hari ini. Ketuk untuk mencatat.',
              style: AppTextStyles.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyLimitCard extends StatelessWidget {
  final int limit;
  final int spent;
  final VoidCallback onTap;

  const _DailyLimitCard({
    required this.limit,
    required this.spent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final over = spent > limit;
    final color = over ? AppColors.expense : AppColors.income;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text('Batas Pengeluaran Harian', style: AppTextStyles.h3),
              ),
              StatusBadge(
                label: over ? 'Terlampaui' : 'Aman',
                icon: over
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
                color: color,
                background: over ? AppColors.expenseSoft : AppColors.incomeSoft,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:
                  limit <= 0 ? 0 : (spent / limit).clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terpakai ${Formatters.rupiah(spent)} dari ${Formatters.rupiah(limit)} hari ini',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
