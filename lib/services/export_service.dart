import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdfx;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../core/utils/formatters.dart';
import '../models/transaction_model.dart';

enum ExportFormat { csv, pdf }

/// Membuat file laporan/cadangan lalu membukanya lewat menu Bagikan Android.
class ExportService {
  ExportService._();

  /// Ekspor memakai menu Bagikan Android.
  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<void> exportTransactions({
    required ExportFormat format,
    required List<TransactionModel> transactions,
    required String Function(String walletId) walletName,
    required String periodLabel,
  }) async {
    final slug = periodLabel
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    switch (format) {
      case ExportFormat.csv:
        final bytes = utf8.encode(
          '\uFEFF${_buildCsv(transactions, walletName)}',
        );
        await _shareBytes(
          bytes: bytes,
          fileName: 'fintrack_$slug.csv',
          mimeType: 'text/csv',
          subject: 'Data transaksi FinTrack',
        );
        break;
      case ExportFormat.pdf:
        final bytes = await _buildPdf(transactions, walletName, periodLabel);
        await _shareBytes(
          bytes: bytes,
          fileName: 'fintrack_laporan_$slug.pdf',
          mimeType: 'application/pdf',
          subject: 'Laporan keuangan FinTrack',
        );
        break;
    }
  }

  static Future<void> shareText({
    required String fileName,
    required String content,
    required String subject,
  }) {
    return _shareBytes(
      bytes: utf8.encode(content),
      fileName: fileName,
      mimeType: 'application/json',
      subject: subject,
    );
  }

  static Future<void> _shareBytes({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required String subject,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType, name: fileName)],
      subject: subject,
    );
  }

  // ----------------------------------------------------------------- CSV

  static String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String _buildCsv(
    List<TransactionModel> txs,
    String Function(String) walletName,
  ) {
    final sorted = List<TransactionModel>.of(txs)
      ..sort((a, b) => a.date.compareTo(b.date));
    final lines = <String>[
      'Tanggal,Waktu,Judul,Jenis,Kategori,Sumber Dana,Nominal,Catatan',
    ];
    for (final t in sorted) {
      lines.add([
        Formatters.shortDate(t.date),
        Formatters.time(t.date),
        _csvField(t.title),
        t.isIncome ? 'Pemasukan' : 'Pengeluaran',
        _csvField(t.category),
        _csvField(walletName(t.walletId)),
        '${t.amount}',
        _csvField(t.note),
      ].join(','));
    }
    return lines.join('\r\n');
  }

  // ----------------------------------------------------------------- PDF

  static pw.Widget _cell(String text, {bool bold = false, bool right = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static Future<List<int>> _buildPdf(
    List<TransactionModel> txs,
    String Function(String) walletName,
    String periodLabel,
  ) async {
    final sorted = List<TransactionModel>.of(txs)
      ..sort((a, b) => a.date.compareTo(b.date));

    var income = 0;
    var expense = 0;
    final byCategory = <String, int>{};
    for (final t in sorted) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }
    }
    final net = income - expense;
    final categories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: pdfx.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'Laporan Keuangan FinTrack',
            style: const pw.TextStyle(
                fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Periode: $periodLabel',
              style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 16),
          pw.Text(
            'Ringkasan',
            style: const pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Pemasukan: ${Formatters.rupiah(income)}'),
          pw.Text('Pengeluaran: ${Formatters.rupiah(expense)}'),
          pw.Text('Surplus bersih: ${Formatters.rupiah(net)}'),
          pw.SizedBox(height: 16),
          if (categories.isNotEmpty) ...[
            pw.Text(
              'Distribusi Pengeluaran',
              style: const pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            for (final c in categories)
              pw.Text(
                '${c.key}: ${Formatters.rupiah(c.value)} (${(c.value * 100 / expense).round()}%)',
              ),
            pw.SizedBox(height: 16),
          ],
          pw.Text(
            'Daftar Transaksi',
            style: const pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border:
                pw.TableBorder.all(color: pdfx.PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2),
              1: pw.FlexColumnWidth(3.2),
              2: pw.FlexColumnWidth(2.6),
              3: pw.FlexColumnWidth(2.4),
              4: pw.FlexColumnWidth(2.4),
            },
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: pdfx.PdfColors.grey200),
                children: [
                  _cell('Tanggal', bold: true),
                  _cell('Judul', bold: true),
                  _cell('Kategori', bold: true),
                  _cell('Sumber Dana', bold: true),
                  _cell('Nominal', bold: true, right: true),
                ],
              ),
              for (final t in sorted)
                pw.TableRow(
                  children: [
                    _cell(Formatters.shortDate(t.date)),
                    _cell(t.title),
                    _cell(t.category),
                    _cell(walletName(t.walletId)),
                    _cell(
                      Formatters.rupiah(t.signedAmount, withSign: true),
                      right: true,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }
}
