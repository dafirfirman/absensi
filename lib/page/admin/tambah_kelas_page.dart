import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator for getting the current location
import 'maps_kelas_page.dart';

class TambahKelasPage extends StatefulWidget {
  @override
  _TambahKelasPageState createState() => _TambahKelasPageState();
}

class _TambahKelasPageState extends State<TambahKelasPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _classNameController = TextEditingController();
  TextEditingController _gradeLevelController = TextEditingController();
  LatLng? _selectedLocation;
  String _currentLocationText = "Belum ditentukan"; // Menampilkan lokasi saat ini

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void dispose() {
    _classNameController.dispose();
    _gradeLevelController.dispose();
    super.dispose();
  }

  // Mendapatkan lokasi saat ini dan menyimpannya
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _currentLocationText =
          "Lokasi saat ini: ${position.latitude}, ${position.longitude}";
    });
  }

  // Fungsi untuk menyimpan data kelas ke backend
  void _saveClass() async {
    if (_formKey.currentState!.validate()) {
      String className = _classNameController.text.trim();
      String gradeLevel = _gradeLevelController.text.trim();

      String url = "http://172.20.10.3/absensi/api/api_tambah_kelas.php";

      Map<String, dynamic> classData = {
        "nama_kelas": className,
        "tingkat": gradeLevel,
        "latitude": _selectedLocation?.latitude ?? '',
        "longitude": _selectedLocation?.longitude ?? '',
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(classData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: responseData['status'] == 'success'
                  ? Colors.green
                  : Colors.red,
            ),
          );

          _classNameController.clear();
          _gradeLevelController.clear();
        } else {
          throw Exception("Gagal menyimpan data kelas. Status code: ${response.statusCode}");
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

  Future<void> _selectLocation() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsPage(initialLocation: _selectedLocation!),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Kelas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5A98CA),
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
                  'Form Tambah Kelas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _classNameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Kelas (contoh: 1A, 2B)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.class_,
                            color: Colors.blueAccent,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Kelas tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _gradeLevelController,
                        decoration: InputDecoration(
                          labelText: 'Tingkat (contoh: 1, 2, 3, ...)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.school,
                            color: Colors.blueAccent,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tingkat Kelas tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Tingkat harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _selectLocation,
                        icon: Icon(Icons.map),
                        label: Text(
                          _selectedLocation == null
                              ? 'Pilih Lokasi Kelas di Peta'
                              : 'Lokasi Dipilih: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(left: 14, right: 14),
                          iconColor: Color(0xFF5A98CA),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _currentLocationText,
                        style: TextStyle(
                            fontSize: 16, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveClass,
                          child: Text(
                            'Simpan Kelas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            iconColor: Color(0xFF5A98CA),
                          ),
                        ),
                      ),
                    ],
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
