import 'package:flutter/material.dart';
// nanti tambah import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () {}),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.analytics_outlined, color: Color(0xFF0C5A3E), size: 24),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Fin', style: TextStyle(color: Colors.black87)),
                  TextSpan(text: 'Track', style: TextStyle(color: Color(0xFF0C5A3E))),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge FinTrack Personal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF0C5A3E)),
                  SizedBox(width: 8),
                  Text('FinTrack Personal', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Judul
            const Text('Selamat Datang Kembali', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
            const SizedBox(height: 12),
            const Text('Masuk untuk melanjutkan kelola catatan keuangan', style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
            const SizedBox(height: 32),

            // Form Email
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Masukkan email anda',
                prefixIcon: const Icon(Icons.alternate_email, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 20),

            // Form Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054))),
                Text('Min. 8 karakter', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Masukkan sandi anda',
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () {
                    setState(() { _obscurePassword = !_obscurePassword; });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 16),

            // Ingat Saya & Lupa Kata Sandi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF0C5A3E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) {
                          setState(() { _rememberMe = value!; });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Ingat Saya', style: TextStyle(color: Color(0xFF344054))),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Lupa Kata Sandi?', style: TextStyle(color: Color(0xFF0C5A3E), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tombol Masuk
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C5A3E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Aksi masuk ke dashboard nantinya
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Daftar Sekarang
            Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  children: [
                    TextSpan(text: 'Belum punya akun? '),
                    TextSpan(text: 'Daftar Sekarang', style: TextStyle(color: Color(0xFF0C5A3E), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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