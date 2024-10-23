import 'package:absensi/page/admin/home_page.dart';
import 'package:absensi/page/kepalasekolah/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nipController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'admin';
  List<String> roles = ['guru', 'admin', 'kepala sekolah'];

  String getApiUrl() {
    switch (_selectedRole) {
      case 'admin':
        return 'http://192.168.1.9/absensi/api/api_login_admin.php';
      case 'kepala sekolah':
        return 'http://192.168.1.9/absensi/api/api_login_kepala_sekolah.php';
      case 'guru':
        return 'http://192.168.1.9/absensi/api/api_login_guru.php';
      default:
        return '';
    }
  }

  Future<void> loginUser() async {
    if (nipController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("NIP/NGTA dan Password harus diisi.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse(getApiUrl());

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nip_ngta": nipController.text,
          "password": passwordController.text,
        }),
      );

      var data = jsonDecode(response.body);

      if (data['status'] == 'success' && data['user'] != null) {
        var nipNgta = data['user']['nip_ngta'];
        var namaLengkap = data['user']['nama_lengkap'];

        if (nipNgta != null && namaLengkap != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('nip_ngta', nipNgta);
          await prefs.setString('nama_lengkap', namaLengkap);
          await prefs.setString('role', _selectedRole);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login berhasil!")),
          );

          navigateToHomePage(nipNgta);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data pengguna tidak lengkap.")),
          );
        }
      } else {
        String message = data['message'] ?? "Login gagal";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan, coba lagi.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToHomePage(String nipNgta) {
    if (_selectedRole == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHomePage(nipNgta: nipNgta),
        ),
      );
    } else if (_selectedRole == 'kepala sekolah') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrincipalHomePage(nipNgta: nipNgta),
        ),
      );
    } else if (_selectedRole == 'guru') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(nipNgta: nipNgta),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/top.png',
              fit: BoxFit.cover,
              height: 150,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/Subtract.png',
              fit: BoxFit.cover,
              height: 150,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 160),
                    Image.asset(
                      'assets/images/logo_sekolah.png',
                      height: 120,
                    ),
                    SizedBox(height: 40),
                    buildTextField(nipController, 'NIP/NGTA', Icons.person, false),
                    SizedBox(height: 20),
                    buildTextField(passwordController, 'Password', Icons.lock, true),
                    SizedBox(height: 20),
                    buildRoleDropdown(),
                    SizedBox(height: 20),
                    buildLoginButton(),
                    SizedBox(height: 20),
                    buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: roles.map((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(
            role == 'guru' ? 'Guru' : role == 'admin' ? 'Admin' : 'Kepala Sekolah',
          ),
        );
      }).toList(),
      onChanged: (String? newRole) {
        setState(() {
          _selectedRole = newRole!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Login sebagai',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 90, 152, 202),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : loginUser,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Widget buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Belum punya akun? "),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
          child: Text(
            "Sign Up",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
