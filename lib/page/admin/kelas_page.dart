import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tambah_kelas_page.dart';

class KelasPage extends StatefulWidget {
  @override
  _KelasPageState createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  List<dynamic> _kelasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKelas(); 
  }

  
  Future<void> _fetchKelas() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.3/absensi/api/api_get_kelas.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _kelasList = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil data kelas.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Kelas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TambahKelasPage()),
              ).then((value) {
                
                _fetchKelas();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _kelasList.isEmpty
              ? Center(child: Text('Tidak ada data kelas.'))
              : ListView.builder(
                  itemCount: _kelasList.length,
                  itemBuilder: (context, index) {
                    final kelas = _kelasList[index];
                    return ListTile(
                      leading: Icon(Icons.class_),
                      title: Text(kelas['nama_kelas']),
                      subtitle: Text("Tingkat: ${kelas['tingkat']}"),
                    );
                  },
                ),
    );
  }
}
