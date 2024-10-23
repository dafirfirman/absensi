import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tambah_lokasi_page.dart';

class SekolahPage extends StatefulWidget {
  @override
  _SekolahPageState createState() => _SekolahPageState();
}

class _SekolahPageState extends State<SekolahPage> {
  List<dynamic> _schoolList = [];

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    String url = "http://192.168.113.97/absensi/api/api_get_sekolah.php";

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
                    title: Text(school['nama_sekolah'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Alamat: ${school['alamat_sekolah']}"),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahLokasiPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
      ),
    );
  }
}
