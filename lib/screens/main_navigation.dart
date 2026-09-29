import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'riwayat_screen.dart';
import 'add_transaction_screen.dart'; // Tambahkan ini
import 'finai_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List ini nanti akan diisi dengan widget dari masing-masing screen
  final List<Widget> _pages = [
    const DashboardScreen(),
    const RiwayatScreen(),
    const FinAIScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      // Tombol Tengah "Catat"
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Buka halaman tambah transaksi dan tunggu sinyal kembalinya
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );

          // Jika result bernilai true (transaksi berhasil disimpan), refresh layar
          if (result == true) {
            setState(() {}); // Memaksa widget membangun ulang dengan data terbaru
          }
        },
        backgroundColor: const Color(0xFF0C5A3E),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Navigasi Bawah
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Memberikan lekukan pada posisi FAB
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Sisi Kiri Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(icon: Icons.grid_view_rounded, label: 'Beranda', index: 0),
                  _buildNavItem(icon: Icons.receipt_long_rounded, label: 'Riwayat', index: 1),
                ],
              ),

              // Sisi Kanan Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(icon: Icons.smart_toy_outlined, label: 'FinAI', index: 2),
                  _buildNavItem(icon: Icons.person_outline, label: 'Profil', index: 3),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi pembuat ikon menu
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isSelected = _currentIndex == index;
    return MaterialButton(
      minWidth: 80,
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0C5A3E) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF0C5A3E) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}