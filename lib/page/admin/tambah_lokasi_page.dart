import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'maps_page.dart';

class TambahLokasiPage extends StatefulWidget {
  @override
  _TambahLokasiPageState createState() => _TambahLokasiPageState();
}

class _TambahLokasiPageState extends State<TambahLokasiPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _schoolNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController(); // Alamat lengkap sekolah
  LatLng? _currentLocation; // Lokasi saat ini

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Mendapatkan lokasi saat ini
  }

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Memeriksa apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Layanan lokasi tidak aktif.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Memeriksa izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin lokasi ditolak.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Izin lokasi ditolak secara permanen.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mendapatkan posisi saat ini
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Mendapatkan alamat dari koordinat
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String fullAddress = '${placemark.street}, ${placemark.subLocality}, '
          '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}, ${placemark.postalCode}';

      _addressController.text = fullAddress;
    }
  }

  // Fungsi untuk menyimpan data lokasi
  void _saveLocation() async {
    if (_formKey.currentState!.validate() && _currentLocation != null) {
      String schoolName = _schoolNameController.text.trim();
      String address = _addressController.text.trim();
      String latitude = _currentLocation!.latitude.toString();
      String longitude = _currentLocation!.longitude.toString();

      // Contoh penyimpanan ke database
      String url = "http://192.168.113.97/absensi/api/api_simpan_lokasi.php"; // Sesuaikan endpoint Anda
      Map<String, dynamic> data = {
        'nama_sekolah': schoolName,
        'alamat_sekolah': address,
        'latitude': latitude,
        'longitude': longitude,
      };

      try {
        final response = await http.post(Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: json.encode(data));

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lokasi berhasil disimpan.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception("Gagal menyimpan data lokasi.");
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
  }

  // Fungsi untuk mendapatkan lokasi baru melalui MapsPage
  Future<void> _selectLocationFromMap() async {
    if (_currentLocation != null) {
      LatLng? selectedLocation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapsPage(initialPosition: _currentLocation!),
        ),
      );

      if (selectedLocation != null) {
        setState(() {
          _currentLocation = selectedLocation;
        });

        // Mendapatkan alamat dari lokasi baru
        List<Placemark> placemarks = await placemarkFromCoordinates(
          selectedLocation.latitude,
          selectedLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          String fullAddress = '${placemark.street}, ${placemark.subLocality}, '
              '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}, ${placemark.postalCode}';

          _addressController.text = fullAddress;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Lokasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Tambah Lokasi Sekolah',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                // Input Nama Sekolah
                TextFormField(
                  controller: _schoolNameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Sekolah',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Sekolah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Alamat Sekolah (otomatis dari lokasi)
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Alamat Sekolah',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat sekolah belum tersedia';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Tombol Pilih Lokasi di Peta
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectLocationFromMap,
                    icon: Icon(Icons.map, color: Colors.blueGrey),
                    label: Text('Pilih Lokasi di Peta', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveLocation,
                    icon: Icon(Icons.save, color: Colors.blueGrey),
                    label: Text('Simpan Lokasi', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
