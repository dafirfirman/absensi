import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'absensi_sekolah_page.dart'; 

class DaftarSekolahPage extends StatefulWidget {
  final String nipNgta; // NIP/Ngta pengguna
  final String namaUser; // Nama pengguna

  DaftarSekolahPage({required this.nipNgta, required this.namaUser});

  @override
  _DaftarSekolahPageState createState() => _DaftarSekolahPageState();
}

class _DaftarSekolahPageState extends State<DaftarSekolahPage> {
  List<dynamic> _schoolList = []; 

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  
  Future<void> _fetchSchools() async {
    String url = "http://192.168.1.9/absensi/api/api_get_sekolah_guru.php"; 

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _schoolList = data;
        });
      } else {
        throw Exception("Gagal mengambil data sekolah.");
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

  
  void _navigateToAbsensiSekolah(String idSekolah, String namaSekolah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbsensiSekolahPage(
          idSekolah: idSekolah, 
          namaSekolah: namaSekolah, 
          nipNgta: widget.nipNgta, 
          namaUser: widget.namaUser, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Sekolah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
      ),
      body: _schoolList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _schoolList.length,
              itemBuilder: (context, index) {
                var school = _schoolList[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      school['nama_sekolah'], 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text("Alamat: ${school['alamat_sekolah']}"),
                    onTap: () {
                      _navigateToAbsensiSekolah(school['id'], school['nama_sekolah']); 
                    },
                  ),
                );
              },
            ),
    );
  }
}
