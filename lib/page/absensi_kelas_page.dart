import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'absen_page.dart';

class AbsensiKelasPage extends StatefulWidget {
  final int userId;

  AbsensiKelasPage({required this.userId});

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<AbsensiKelasPage> {
  List<dynamic> _jadwal = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

 
  Future<void> _fetchJadwal() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.9/absensi/api/jadwal_kelas.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _jadwal = data['jadwal'];
            _isLoading = false; 
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data: ${data['message']}')),
          );
        }
      } else {
        throw Exception('Failed to load jadwal');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  
  String _getInitial(String mataPelajaran) {
    return mataPelajaran.isNotEmpty ? mataPelajaran[0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        title: Text('Absensi Kelas',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) 
          : _jadwal.isEmpty
              ? Center(
                  child: Text('Tidak ada data jadwal',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
              : ListView.builder(
                  padding: EdgeInsets.all(16), 
                  itemCount: _jadwal.length,
                  itemBuilder: (context, index) {
                    final jadwal = _jadwal[index];
                    final initial = _getInitial(
                        jadwal['mata_pelajaran']); 

                    return GestureDetector(
                      
                      onTap: () {
                       
                        if (jadwal['latitude'] != null &&
                            jadwal['longitude'] != null &&
                            jadwal['kelas_id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AbsenPage(
                                mataPelajaran: jadwal['mata_pelajaran'],
                                namaKelas: jadwal['nama_kelas'],
                                latitude: double.parse(
                                    jadwal['latitude']), 
                                longitude: double.parse(
                                    jadwal['longitude']), 
                                userId:
                                    widget.userId,
                                kelasId: int.parse(jadwal['kelas_id']
                                    .toString()),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Data tidak lengkap: Latitude, Longitude, atau Kelas ID tidak tersedia.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin:
                            EdgeInsets.only(bottom: 16), 
                        elevation: 4, 
                        child: Padding(
                          padding: EdgeInsets.all(16), 
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.blueAccent, 
                                  shape: BoxShape.circle, 
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 16), 
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${jadwal['mata_pelajaran']} - ${jadwal['nama_kelas']}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${jadwal['hari']} | ${jadwal['waktu_mulai']} - ${jadwal['waktu_selesai']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
