import '../core/utils/finai_engine.dart';
import '../models/transaction_model.dart';

/// Data yang diberikan ke FinAI untuk menjawab sebuah pertanyaan.
class FinAIContext {
  final List<TransactionModel> transactions;
  final DateTime anchor;
  final int totalBalance;

  const FinAIContext({
    required this.transactions,
    required this.anchor,
    required this.totalBalance,
  });
}

/// Kontrak FinAI.
///
/// UI hanya bergantung pada kelas ini. Saat AI sungguhan siap, cukup buat
/// implementasi baru (mis. `RemoteFinAIService` yang memanggil backend/LLM)
/// lalu ganti satu baris di `main.dart`. Layar tidak perlu diubah.
///
/// Implementasi boleh melempar exception; layar akan menampilkan pesan gagal.
abstract class FinAIService {
  Future<String> reply(String question, FinAIContext context);
}

/// Implementasi sementara: jawaban dihitung dari aturan lokal
/// ([FinAIEngine]), BUKAN model AI.
class RuleBasedFinAIService implements FinAIService {
  const RuleBasedFinAIService({
    this.latency = const Duration(milliseconds: 700),
  });

  /// Jeda buatan agar terasa seperti "mengetik". Set `Duration.zero` di test.
  final Duration latency;

  @override
  Future<String> reply(String question, FinAIContext context) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return FinAIEngine.reply(
      question: question,
      txs: context.transactions,
      anchor: context.anchor,
      totalBalance: context.totalBalance,
    );
  }
}
