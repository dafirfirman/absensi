import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tambah_jadwal_page.dart';

class JadwalPage extends StatefulWidget {
  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<dynamic> _jadwalList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    try {
      final response = await http
          .get(Uri.parse('http://172.20.10.3/absensi/api/api_get_jadwal.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _jadwalList = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil data jadwal.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Jadwal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TambahJadwalPage()),
              ).then((value) {
                _fetchJadwal();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _jadwalList.isEmpty
              ? Center(child: Text('Tidak ada jadwal tersedia.'))
              : ListView.builder(
                  itemCount: _jadwalList.length,
                  itemBuilder: (context, index) {
                    final jadwal = _jadwalList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.schedule),
                        title:
                            Text("Mata Pelajaran: ${jadwal['mata_pelajaran']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Kelas: ${jadwal['nama_kelas']}"),
                            Text("Hari: ${jadwal['hari']}"),
                            Text(
                                "Jam: ${jadwal['waktu_mulai']} - ${jadwal['waktu_selesai']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
