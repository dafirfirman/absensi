import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TambahDataGuruPage extends StatefulWidget {
  @override
  _TambahDataGuruPageState createState() => _TambahDataGuruPageState();
}

class _TambahDataGuruPageState extends State<TambahDataGuruPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _nipController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _positionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nipController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // Simpan data guru
  void _saveTeacherData() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String nip = _nipController.text.trim();
      String email = _emailController.text.trim();
      String phone = _phoneController.text.trim();
      String address = _addressController.text.trim();
      String position = _positionController.text.trim();

      // URL endpoint backend
      String url = "http://172.20.10.3/absensi/api/api_tambah_guru.php"; // Sesuaikan alamat server

      // Data yang akan dikirim ke backend
      Map<String, dynamic> teacherData = {
        "nama_guru": name,
        "nip": nip,
        "email": email,
        "telepon": phone,
        "alamat": address,
        "jabatan": position,
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(teacherData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          if (responseData['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message']),
                backgroundColor: Colors.green,
              ),
            );

            // Kosongkan form setelah berhasil disimpan
            _nameController.clear();
            _nipController.clear();
            _emailController.clear();
            _phoneController.clear();
            _addressController.clear();
            _positionController.clear();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          throw Exception("Gagal menyimpan data. Status code: ${response.statusCode}");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data Guru', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Form Tambah Data Guru',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                SizedBox(height: 16),
                // Input fields as before, with new fields for Address and Position
                // Input Nama Guru
                _buildTextInput("Nama Guru", _nameController, Icons.person),
                // Input NIP Guru
                _buildTextInput("NIP", _nipController, Icons.badge, isNumber: true),
                // Input Email Guru
                _buildTextInput("Email", _emailController, Icons.email, isEmail: true),
                // Input Nomor Telepon Guru
                _buildTextInput("Nomor Telepon", _phoneController, Icons.phone, isNumber: true),
                // Input Alamat Guru
                _buildTextInput("Alamat", _addressController, Icons.location_city),
                // Input Jabatan Guru
                _buildTextInput("Jabatan", _positionController, Icons.work),

                SizedBox(height: 24),
                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTeacherData,
                    child: Text('Simpan Data Guru', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create text input fields
  Widget _buildTextInput(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Email tidak valid';
          }
          return null;
        },
      ),
    );
  }
}
