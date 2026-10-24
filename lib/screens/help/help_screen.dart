import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar/app_header.dart';
import '../../widgets/common/app_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<MapEntry<String, String>> _faqs = [
    MapEntry(
      'Bagaimana cara mencatat transaksi?',
      'Tekan tombol "+" di tengah navigasi bawah, pilih Pengeluaran atau Pemasukan, isi nominal, pilih kategori (atau pilih Kategori Lain untuk mengetik sendiri), dan sumber dana, lalu tekan Simpan Transaksi.',
    ),
    MapEntry(
      'Bagaimana mengubah atau menghapus transaksi?',
      'Buka tab Transaksi, ketuk transaksi yang diinginkan, lalu pilih Ubah Data atau Hapus di halaman detail. Saldo dompet akan menyesuaikan otomatis.',
    ),
    MapEntry(
      'Bagaimana cara menambah dompet?',
      'Dari Beranda tekan Kelola Dompet, lalu + Tambah Dompet. Dompet bisa diubah atau dihapus lewat menu titik tiga, selama belum dipakai transaksi.',
    ),
    MapEntry(
      'Apa itu batas pengeluaran harian?',
      'Batas yang kamu tetapkan di menu Profil atau lewat FinAI. Beranda menampilkan pemakaian hari ini terhadap batas tersebut.',
    ),
    MapEntry(
      'Bagaimana mengekspor laporan?',
      'Buka Profil > Ekspor Data Finansial, pilih periode dan format (PDF atau CSV), lalu bagikan file yang dibuat.',
    ),
    MapEntry(
      'Apakah data saya aman?',
      'Data tersimpan di perangkat ini saja dan tidak dikirim ke server. PIN disimpan dalam bentuk hash.',
    ),
    MapEntry(
      'Apakah FinAI memakai AI sungguhan?',
      'Belum. FinAI di prototype ini adalah asisten berbasis aturan yang menghitung jawaban dari data transaksimu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AppHeader(showBack: true),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                children: [
                  Text('Pusat Bantuan & FAQ', style: AppTextStyles.h1),
                  const SizedBox(height: 16),
                  for (final f in _faqs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        radius: 16,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            title: Text(
                              f.key,
                              style: AppTextStyles.label.copyWith(fontSize: 14),
                            ),
                            children: [
                              Text(f.value, style: AppTextStyles.bodySecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
