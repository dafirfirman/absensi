import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiwayatPage extends StatefulWidget {
  final String nipNgta;

  RiwayatPage({required this.nipNgta});

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> riwayatList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayatAbsensi();
  }

  Future<void> fetchRiwayatAbsensi() async {
    final url = Uri.parse('http://192.168.1.9/absensi/api/riwayat_absensi.php');
    final response = await http.post(
      url,
      body: {'user_id': widget.nipNgta},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        riwayatList = data.map((item) => {
          'status': item['status'],
          'waktu_absen': item['waktu_absen'],
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Jika ada error atau data tidak ditemukan
      print('Gagal mengambil data riwayat: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : riwayatList.isEmpty
              ? const Center(child: Text('Tidak ada riwayat absen.'))
              : ListView.builder(
                  itemCount: riwayatList.length,
                  itemBuilder: (context, index) {
                    final riwayat = riwayatList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.blueAccent),
                        title: Text(
                          riwayat['status']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          riwayat['waktu_absen']!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }
}
