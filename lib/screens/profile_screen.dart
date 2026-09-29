import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../data/dummy_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  void _logoutProcess() async {
    setState(() { _isLoading = true; });

    // Simulasi proses menghapus sesi dari server lokal
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Gunakan pushAndRemoveUntil agar pengguna tidak bisa kembali ke halaman profil setelah logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  // Fungsi untuk memunculkan dialog konfirmasi
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Menutup dialog jika batal
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(ctx); // Tutup dialog terlebih dahulu
                _logoutProcess();   // Kemudian jalankan proses loading dan logout
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Komponen pembuat list menu yang dapat digunakan berulang
  Widget _buildMenuOption(IconData icon, String title, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0C5A3E)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil jumlah transaksi secara dinamis dari data simulasi
    final int totalCatatan = dummyTransactions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Header Profil Utama
            const Text('Fin Track', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
            const SizedBox(height: 4),
            const Text('fintrack@email.com', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 12),

            // Badge Akun Personal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FADF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.verified, color: Color(0xFF039855), size: 18),
                  SizedBox(width: 6),
                  Text('Akun Personal', style: TextStyle(color: Color(0xFF027A48), fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Kartu Statistik (Total Catatan & Anggota)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('Total Catatan', style: TextStyle(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('$totalCatatan', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                        const SizedBox(height: 4),
                        const Text('Transaksi', style: TextStyle(color: Color(0xFF039855), fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('Anggota', style: TextStyle(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 8),
                        const Text('Januari', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                        const SizedBox(height: 4),
                        const Text('2024', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 3. Opsi Menu
            _buildMenuOption(Icons.person_outline, 'Pengaturan Akun', onTap: () {}),
            _buildMenuOption(Icons.description_outlined, 'Ekspor Laporan (PDF)', onTap: () {}),
            _buildMenuOption(Icons.help_outline, 'Bantuan & Dukungan', onTap: () {}),

            const SizedBox(height: 40),

            // 4. Tombol Keluar (Logout)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _showLogoutConfirmation, // Memanggil dialog
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Keluar Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}