import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController nipController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> registerUser() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // URL endpoint API
    var url = Uri.parse('http://192.168.113.97/absensi/api/api_register.php');

    // Body request dalam format JSON
    var requestBody = json.encode({
      "nama_guru": namaController.text,
      "nip_ngta": nipController.text,
      "password": passwordController.text,
    });

    try {
      // Mengirim request POST dengan body JSON
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // Menandakan body berformat JSON
        },
        body: requestBody,
      );

      // Mengecek status kode respons
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (mounted) {
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );

            // Mengosongkan form setelah registrasi berhasil
            _formKey.currentState!.reset();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );
          }
        }
      } else {
        // Menampilkan pesan error jika gagal menghubungi server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghubungi server. Coba lagi!')),
        );
      }
    } catch (e) {
      // Menampilkan pesan jika terjadi error koneksi atau lainnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Latar atas
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
          // Latar bawah
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
          // Form Registrasi
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
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Input Nama Lengkap
                          TextFormField(
                            controller: namaController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama Lengkap tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Input NIP/NGTA
                          TextFormField(
                            controller: nipController,
                            decoration: InputDecoration(
                              labelText: 'NIP/NGTA',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'NIP/NGTA tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Input Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Icon(Icons.lock),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              } else if (value.length < 6) {
                                return 'Password harus lebih dari 6 karakter';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Tombol "Sign Up"
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 90, 152, 202),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  registerUser();
                                }
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Link ke halaman login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Sudah punya akun? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
