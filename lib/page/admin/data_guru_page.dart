import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/page/admin/tambah_data_guru_page.dart';

class DataGuruPage extends StatefulWidget {
  @override
  _DataGuruPageState createState() => _DataGuruPageState();
}

class _DataGuruPageState extends State<DataGuruPage> {
  List<dynamic> guruList = [];

  @override
  void initState() {
    super.initState();
    fetchDataGuru();
  }

  Future<void> fetchDataGuru() async {
    String url = "http://192.168.113.97/absensi/api/api_data_guru.php";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          guruList = json.decode(response.body);
        });
      } else {
        throw Exception("Gagal mengambil data guru.");
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
          'Data Guru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TambahDataGuruPage()),
              ).then((_) {
                fetchDataGuru();
              });
            },
          ),
        ],
      ),
      body: guruList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: guruList.length,
              itemBuilder: (context, index) {
                final guru = guruList[index];
                return ListTile(
                  title: Text(guru['nama_guru']),
                  subtitle: Text(guru['jabatan']),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {},
                );
              },
            ),
    );
  }
}
