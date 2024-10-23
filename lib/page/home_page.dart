import 'package:absensi/page/riwayat_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart'; // Import halaman profil
import 'daftar_sekolah_page.dart'; // Import halaman daftar sekolah
import 'absensi_kelas_page.dart'; // Import halaman Absensi Kelas
import 'login_page.dart'; // Import halaman Login

class HomePage extends StatefulWidget {
  final String nipNgta;

  HomePage({required this.nipNgta});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? nipNgta;

  @override
  void initState() {
    super.initState();
    getUserData(); // Ambil nama pengguna dan nip/ngta saat inisialisasi
  }

  // Fungsi untuk mengambil nama pengguna dan nip/ngta dari SharedPreferences
  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('nama_lengkap') ??
          'User'; // Ambil nama dari SharedPreferences
      nipNgta = prefs.getString('nip_ngta') ??
          'N/A'; // Ambil nip/ngta dari SharedPreferences
    });
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data dari SharedPreferences
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => LoginPage())); // Navigasi ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        automaticallyImplyLeading: false, // Menghilangkan back button
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hi, $userName',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridMenu([
                MenuCard(
                  icon: Icons.school,
                  title: 'Absensi Sekolah',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DaftarSekolahPage(
                          nipNgta: nipNgta ?? 'N/A',
                          namaUser: userName ?? 'User',
                        ),
                      ),
                    );
                  },
                ),
                MenuCard(
                  icon: Icons.class_,
                  title: 'Absensi Kelas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AbsensiKelasPage(
                          userId: int.tryParse(nipNgta ?? '0') ?? 0,
                        ),
                      ),
                    );
                  },
                ),
                MenuCard(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: logout,
                ),
                MenuCard(
                icon: Icons.history,
                title: 'Riwayat',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiwayatPage(
                        nipNgta: nipNgta ?? 'N/A',
                      ),
                    ),
                  );
                },
              ),

              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class GridMenu extends StatelessWidget {
  final List<MenuCard> menus;

  GridMenu(this.menus);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: menus,
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;

  MenuCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.blueAccent,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
