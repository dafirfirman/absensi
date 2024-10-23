import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class AbsensiSekolahPage extends StatefulWidget {
  final String idSekolah; // ID sekolah yang dipilih
  final String namaSekolah; // Nama sekolah yang dipilih
  final String nipNgta; // NIP/Ngta pengguna
  final String namaUser; // Nama pengguna

  AbsensiSekolahPage(
      {required this.idSekolah,
      required this.namaSekolah,
      required this.nipNgta,
      required this.namaUser});

  @override
  _AbsensiSekolahPageState createState() => _AbsensiSekolahPageState();
}

class _AbsensiSekolahPageState extends State<AbsensiSekolahPage> {
  String statusKehadiran = "Belum absen";
  bool isWithinArea = false;
  bool isLoading = false;
  double? schoolLatitude;
  double? schoolLongitude;
  final double allowedRadius = 100.0;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    fetchSchoolLocation();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      setState(() {
        statusKehadiran = "Izin lokasi tidak diberikan";
      });
    }
  }

  Future<void> fetchSchoolLocation() async {
    String url =
        "http://192.168.1.9/absensi/api/api_get_lokasi_sekolah.php?id_sekolah=${widget.idSekolah}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          setState(() {
            schoolLatitude = double.parse(data['latitude']);
            schoolLongitude = double.parse(data['longitude']);
          });
        } else {
          setState(() {
            statusKehadiran =
                "Data sekolah tidak lengkap. Pastikan API mengembalikan latitude dan longitude.";
          });
        }
      } else {
        setState(() {
          statusKehadiran =
              "Gagal mengambil lokasi sekolah. Cek koneksi atau ID sekolah.";
        });
      }
    } catch (e) {
      setState(() {
        statusKehadiran = "Terjadi kesalahan: $e";
      });
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      setState(() {
        statusKehadiran = "Gagal mendapatkan lokasi: $e";
      });
      return null;
    }
  }

  Future<void> checkLocation() async {
    if (schoolLatitude == null || schoolLongitude == null) {
      setState(() {
        statusKehadiran = "Lokasi sekolah belum siap.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    Position? userLocation = await getCurrentLocation();
    if (userLocation != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        schoolLatitude!,
        schoolLongitude!,
      );

      if (distanceInMeters <= allowedRadius) {
        setState(() {
          isWithinArea = true;
          statusKehadiran = "Anda berada di area sekolah, absen berhasil!";
        });
        saveAttendance("Hadir");
      } else {
        setState(() {
          isWithinArea = false;
          statusKehadiran = "Anda berada di luar area sekolah.";
          _showStatusDialog();
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveAttendance(String status) async {
    String url = "http://192.168.1.9/absensi/api/api_simpan_absensi.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'nip_ngta': widget.nipNgta,
          'nama': widget.namaUser,
          'id_sekolah': widget.idSekolah,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Absensi berhasil disimpan sebagai $status')),
        );
      } else {
        throw Exception('Gagal menyimpan absensi');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pilih Status Kehadiran"),
          content:
              Text("Anda berada di luar area sekolah. Pilih status kehadiran:"),
          actions: <Widget>[
            TextButton(
              child: Text("Sakit"),
              onPressed: () {
                Navigator.of(context).pop();
                saveAttendance("Sakit");
              },
            ),
            TextButton(
              child: Text("Izin"),
              onPressed: () {
                Navigator.of(context).pop();
                saveAttendance("Izin");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        title: Text(
          'Absensi - ${widget.namaSekolah}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isWithinArea
                      ? Icons.check_circle_outline
                      : Icons.location_off,
                  color: isWithinArea ? Colors.green : Colors.red,
                  size: 100,
                ),
                SizedBox(height: 20),
                Text(
                  statusKehadiran,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : ElevatedButton(
                        onPressed: checkLocation,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                          iconColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cek Kehadiran',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
