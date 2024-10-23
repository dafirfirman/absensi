import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileLengkapPage extends StatefulWidget {
  @override
  _ProfileLengkapPageState createState() => _ProfileLengkapPageState();
}

class _ProfileLengkapPageState extends State<ProfileLengkapPage> {
  String? nipNgta;
  String? userName;
  String? email;
  String? telepon;
  String? alamat;
  String? jabatan;
  String? tempatLahir;
  String? tanggalLahir;
  String? agama;
  String? pendidikanTerakhir;
  String? pangkat;

  final List<String> _agamaOptions = [
    'Islam',
    'Kristen Protestan',
    'Kristen Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _loadNipNgta();
  }

  Future<void> _loadNipNgta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nipNgta = prefs.getString('nip_ngta');
    });

    if (nipNgta != null) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    var apiUrl = 'http://192.168.1.9/absensi/api/api_get_profile.php';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"nip_ngta": nipNgta}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['user'] != null) {
          setState(() {
            userName = data['user']['nama_guru'];
            email = data['user']['email'];
            telepon = data['user']['telepon'];
            alamat = data['user']['alamat'];
            jabatan = data['user']['jabatan'];
            tempatLahir = data['user']['tempat_lahir'];
            tanggalLahir = data['user']['tanggal_lahir'];
            agama = data['user']['agama'];
            pendidikanTerakhir = data['user']['pendidikan'];
            pangkat = data['user']['pangkat'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data tidak ditemukan')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data dari server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }

  Future<void> _saveProfileData(String key, String value) async {
    var apiUrl = 'http://192.168.1.9/absensi/api/api_update_profile.php';

    Map<String, dynamic> requestData = {
      "nip_ngta": nipNgta,
      "nama_guru": userName,
      "email": email,
      "telepon": telepon,
      "alamat": alamat,
      "jabatan": jabatan,
      "tempat_lahir": tempatLahir,
      "tanggal_lahir": tanggalLahir,
      "agama": agama,
      "pendidikan": pendidikanTerakhir,
      "pangkat": pangkat,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil diperbarui')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal memperbarui data: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghubungi server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Lengkap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildReadonlyField('NIP/NGTA', nipNgta),
            _buildProfileField('Nama Lengkap', userName, 'nama_guru'),
            _buildProfileField('Email', email, 'email'),
            _buildProfileField('Telepon', telepon, 'telepon'),
            _buildProfileField('Alamat', alamat, 'alamat'),
            _buildProfileField('Jabatan', jabatan, 'jabatan'),
            _buildProfileField('Tempat Lahir', tempatLahir, 'tempat_lahir'),
            _buildDateField('Tanggal Lahir', tanggalLahir),
            _buildAgamaDropdown(),
            _buildProfileField(
                'Pendidikan Terakhir', pendidikanTerakhir, 'pendidikan'),
            _buildProfileField('Pangkat', pangkat, 'pangkat'),
          ],
        ),
      ),
    );
  }

  Widget _buildReadonlyField(String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value ?? 'Tidak tersedia'),
      leading: Icon(Icons.lock),
    );
  }

  Widget _buildProfileField(String label, String? value, String key) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value ?? 'Belum diisi'),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          _showEditDialog(label, key, value);
        },
      ),
    );
  }

  Widget _buildDateField(String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value ?? 'Belum diisi'),
      trailing: IconButton(
        icon: Icon(Icons.calendar_today),
        onPressed: () async {
          DateTime? initialDate;
          try {
            initialDate =
                value != null ? DateTime.parse(value) : DateTime.now();
          } catch (e) {
            initialDate = DateTime.now();
          }

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            setState(() {
              tanggalLahir =
                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            });
            _saveProfileData('tanggal_lahir', tanggalLahir!);
          }
        },
      ),
    );
  }

  Widget _buildAgamaDropdown() {
    return ListTile(
      title: Text('Agama'),
      subtitle: DropdownButton<String>(
        value: _agamaOptions.contains(agama) ? agama : null,
        isExpanded: true,
        hint: Text('Pilih Agama'),
        items: _agamaOptions.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            agama = newValue;
          });
          if (agama != null) {
            _saveProfileData('agama', agama!);
          }
        },
      ),
    );
  }

  void _showEditDialog(String title, String key, String? currentValue) {
    TextEditingController _controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Masukkan $title baru'),
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Simpan'),
              onPressed: () {
                setState(() {
                  if (key == 'nama_guru') userName = _controller.text;
                  if (key == 'email') email = _controller.text;
                  if (key == 'telepon') telepon = _controller.text;
                  if (key == 'alamat') alamat = _controller.text;
                  if (key == 'jabatan') jabatan = _controller.text;
                  if (key == 'tempat_lahir') tempatLahir = _controller.text;
                  if (key == 'pendidikan')
                    pendidikanTerakhir = _controller.text;
                  if (key == 'pangkat') pangkat = _controller.text;
                });
                _saveProfileData(key, _controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
