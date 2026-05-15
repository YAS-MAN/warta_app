import 'package:flutter/material.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../home/home_view.dart';
import '../surat/surat_view.dart';
import '../aktivitas/aktivitas_view.dart';
import '../profil/profil_view.dart';
import '../report/lapor_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  // Memanggil ViewModel
  final MainViewModel _viewModel = MainViewModel();

  // Daftar halaman yang akan ditampilkan sesuai urutan tab
  late final List<Widget> _pages;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _viewModel.currentIndex);
    
    // Sinkronisasi perubahan ViewModel ke PageController dengan animasi
    _viewModel.addListener(() {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _viewModel.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    _pages = [
      HomeView(onNavigate: _viewModel.setIndex), // Index 0
      SuratView(onNavigate: _viewModel.setIndex), // Index 1
      const SizedBox(), // Index 2 (Dikosongkan karena ini area tombol Kamera)
      const AktivitasView(), // Index 3
      const ProfilView(), // Index 4
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder akan memantau perubahan dari MainViewModel
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          // Menggunakan PageView untuk transisi bergeser horizontal
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Nonaktifkan swipe jari
            children: _pages,
          ),

          // Tombol Kamera (E-Report) melayang di tengah
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigasi tumpuk (Push) ke halaman Lapor
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LaporView()),
              );
            },
            backgroundColor: const Color(0xFFD4AF37),
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 4),
            ),
            elevation: 6,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          // Bottom Navigation Bar WARTA
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.home, "Home", 0),
                  _buildBottomNavItem(Icons.mail, "Surat", 1),
                  const SizedBox(width: 48), // Ruang kosong untuk kamera
                  _buildBottomNavItem(Icons.history, "Aktivitas", 3),
                  _buildBottomNavItem(Icons.person, "Profil", 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi pembuat tombol Navigasi Bawah (Anti-Goyang)
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isActive = _viewModel.currentIndex == index;
    final primaryRed = const Color(0xFF8B0000);
    final greyColor = const Color(0xFF9CA3AF);

    return InkWell(
      onTap: () => _viewModel.setIndex(index), // Mengubah state via ViewModel
      borderRadius: BorderRadius.circular(16), // Efek klik melengkung
      child: Container(
        width: 65, // KUNCI UTAMA: Lebar tetap agar tidak mendorong ikon lain
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          // Munculkan background merah transparan hanya saat aktif
          color: isActive ? primaryRed.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Posisi Ikon selalu di atas
            Icon(icon, color: isActive ? primaryRed : greyColor, size: 24),
            const SizedBox(height: 4),
            // Posisi Teks selalu di bawah
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryRed : greyColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
