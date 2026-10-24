import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_clock.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/finai_engine.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_state.dart';
import '../../services/finai_service.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/chat/finai_message_bubble.dart';
import '../../widgets/chat/user_message_bubble.dart';
import '../../widgets/common/app_card.dart';

class _ChatMessage {
  final bool isUser;
  final String text;
  final String? title;
  final List<MapEntry<String, String>> details;

  const _ChatMessage({
    required this.isUser,
    required this.text,
    this.title,
    this.details = const [],
  });
}

class FinAIScreen extends StatefulWidget {
  const FinAIScreen({super.key});

  @override
  State<FinAIScreen> createState() => _FinAIScreenState();
}

class _FinAIScreenState extends State<FinAIScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _typing = false;

  static const List<String> _quickQuestions = [
    'Analisis kebiasaan belanja',
    'Rekomendasi penghematan',
    'Bagaimana cara menabung?',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final report =
        FinAIEngine.monthReport(state.transactions, AppClock.today());
    final name = state.currentUser?.name.split(' ').first ?? 'kamu';

    _messages.addAll([
      _ChatMessage(
        isUser: false,
        text:
            'Halo $name! Saya telah menganalisis transaksimu bulan ini. Tanyakan apa saja seputar keuanganmu.',
      ),
      const _ChatMessage(
        isUser: true,
        text:
            'Bisa berikan analisis apakah pengeluaranku aman untuk beli laptop baru depan?',
      ),
      _ChatMessage(
        isUser: false,
        title:
            'Analisis Kelayakan Finansial: ${report.net > 0 ? 'Aman' : 'Perlu Hati-hati'}',
        details: [
          MapEntry('Pemasukan', Formatters.rupiah(report.income)),
          MapEntry('Pengeluaran', Formatters.rupiah(report.expense)),
          MapEntry('Surplus', Formatters.rupiah(report.net)),
          MapEntry('Total saldo', Formatters.rupiah(state.totalBalance)),
        ],
        text:
            'Rekomendasi: sisihkan sebagian surplus tiap bulan ke dompet khusus laptop. Sebutkan harga targetmu (mis. "laptop 12 juta") untuk hitungan lebih tepat.',
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Perintah yang mengubah pengaturan aplikasi (bukan pertanyaan analisis).
  /// Mengembalikan null jika [text] bukan perintah.
  String? _localCommand(String text, AppState state) {
    final q = text.toLowerCase();
    if (!q.contains('batas')) return null;

    if (q.contains('hapus') || q.contains('matikan')) {
      state.setDailyLimit(null);
      return 'Batas pengeluaran harian dihapus.';
    }
    final amount = FinAIEngine.parseAmount(q);
    if (amount == null) {
      return 'Sebutkan nominalnya, mis. "Pasang batas harian 150rb".';
    }
    state.setDailyLimit(amount);
    return 'Batas pengeluaran harian ${Formatters.rupiah(amount)} aktif. Pemakaian harianmu kini tampil di Beranda.';
  }

  Future<String> _answer(String text, AppState state) async {
    final command = _localCommand(text, state);
    if (command != null) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return command;
    }
    try {
      return await context.read<FinAIService>().reply(
            text,
            FinAIContext(
              transactions: state.transactions,
              anchor: AppClock.today(),
              totalBalance: state.totalBalance,
            ),
          );
    } catch (_) {
      return 'Maaf, FinAI sedang tidak dapat menjawab. Coba lagi sebentar.';
    }
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _typing) return;

    final state = context.read<AppState>();
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _typing = true;
      _controller.clear();
    });
    _scrollToEnd();

    final answer = await _answer(text, state);
    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(isUser: false, text: answer));
      _typing = false;
    });
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final report =
        FinAIEngine.monthReport(state.transactions, AppClock.today());
    // Tombol "+" disembunyikan saat keyboard terbuka, jadi ruangnya tidak perlu.
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AppHeader(
            showNotification: true,
            overline: 'FINAI ASSISTANT • v2.4',
            title: 'FinAI Assistant',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: AppColors.income),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'FinAI • Asisten Keuangan (berbasis aturan)',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            children: [
              _SmartSummary(
                shoppingRatio: FinAIEngine.shoppingRatio(report),
                saving: FinAIEngine.savingPotential(report),
                onTip: _send,
              ),
              const SizedBox(height: 16),
              for (final m in _messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: m.isUser
                      ? UserMessageBubble(text: m.text)
                      : FinAIMessageBubble(
                          text: m.text,
                          title: m.title,
                          details: m.details,
                        ),
                ),
              if (_typing)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: FinAIMessageBubble(text: 'FinAI sedang mengetik...'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _quickQuestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => ActionChip(
              label: Text(_quickQuestions[i]),
              onPressed: () => _send(_quickQuestions[i]),
              backgroundColor: AppColors.lightGreen,
              side: BorderSide.none,
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            keyboardOpen ? 10 : 10 + AppConstants.fabClearance,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                  decoration: const InputDecoration(
                    hintText: 'Tanyakan apa saja seputar keuangan',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Kirim',
                onPressed: () => _send(_controller.text),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(52, 52),
                ),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmartSummary extends StatelessWidget {
  final int shoppingRatio;
  final int saving;
  final ValueChanged<String> onTip;

  const _SmartSummary({
    required this.shoppingRatio,
    required this.saving,
    required this.onTip,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.lavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RINGKASAN CERDAS BULAN INI',
            style: AppTextStyles.overline.copyWith(color: AppColors.purple),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child:
                    _Metric(label: 'Rasio Belanja', value: '$shoppingRatio%'),
              ),
              Expanded(
                child: _Metric(
                  label: 'Potensi Simpanan',
                  value: Formatters.rupiah(saving),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.savings_outlined, size: 18),
                label: const Text('Pasang Batas Harian Rp150rb'),
                onPressed: () => onTip('Pasang batas harian 150rb'),
                backgroundColor: AppColors.surface,
                side: BorderSide.none,
              ),
              ActionChip(
                avatar: const Icon(Icons.coffee_outlined, size: 18),
                label: const Text('Tips Hemat Kopi Mingguan'),
                onPressed: () => onTip('Tips hemat kopi'),
                backgroundColor: AppColors.surface,
                side: BorderSide.none,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppTextStyles.h2),
        ),
      ],
    );
  }
}
