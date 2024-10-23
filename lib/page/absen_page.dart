import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

class AbsenPage extends StatefulWidget {
  final String mataPelajaran;
  final String namaKelas;
  final double latitude; 
  final double longitude; 
  final int kelasId; 
  final int userId;

  AbsenPage({
    required this.mataPelajaran,
    required this.namaKelas,
    required this.latitude, 
    required this.longitude,
    required this.kelasId, 
    required this.userId,
  });

  @override
  _AbsenPageState createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  bool _isAtLocation = false;
  String _message = 'Memeriksa lokasi...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _message = 'Layanan lokasi tidak aktif. Aktifkan layanan lokasi untuk absensi.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _message = 'Izin lokasi ditolak. Tidak dapat melakukan absensi.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _message = 'Izin lokasi diblokir secara permanen. Buka pengaturan untuk memberikan izin.';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.latitude,
        widget.longitude,
      );

      if (distanceInMeters <= 100) {
        setState(() {
          _isAtLocation = true;
          _message = 'Anda berada di lokasi yang ditentukan. Silakan lakukan absensi.';
        });
      } else {
        setState(() {
          _isAtLocation = false;
          _message = 'Anda tidak berada di lokasi yang ditentukan. Tidak dapat melakukan absensi.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Terjadi kesalahan saat mendapatkan lokasi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAbsensi() async {
    final apiUrl = 'http://192.168.1.9/absensi/api/simpan_absensi.php';

    // Mendapatkan waktu saat ini dan mengonversinya ke zona WIB
    DateTime waktuSekarang = DateTime.now().toUtc().add(Duration(hours: 7));
    String waktuWIB = waktuSekarang.toIso8601String(); // Format ISO 8601 untuk konsistensi

    // Data absensi dengan waktu dalam zona WIB
    Map<String, dynamic> absensiData = {
      'kelas_id': widget.kelasId,
      'user_id': widget.userId,
      'status': _isAtLocation ? 'hadir' : 'tidak hadir',
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'waktu_absen': waktuWIB, // Menyertakan waktu dalam zona WIB
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(absensiData),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Absensi berhasil disimpan untuk ${widget.mataPelajaran}.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan absensi: ${jsonResponse['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan absensi, server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat menyimpan absensi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _doAbsensi() {
    if (_isAtLocation) {
      _submitAbsensi();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anda tidak berada di lokasi yang ditentukan.'),
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
          'Absen - ${widget.mataPelajaran}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5A98CA),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Absensi Kelas',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Mata Pelajaran: ${widget.mataPelajaran}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Kelas: ${widget.namaKelas}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              child: Text(
                                _message,
                                key: ValueKey<String>(_message),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _isAtLocation ? Colors.green : Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _doAbsensi,
                              icon: Icon(Icons.fingerprint, size: 28),
                              label: Text(
                                'Lakukan Absensi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 40),
                                iconColor: _isAtLocation ? Colors.green : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
