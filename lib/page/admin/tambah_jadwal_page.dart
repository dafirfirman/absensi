import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TambahJadwalPage extends StatefulWidget {
  @override
  _TambahJadwalPageState createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _subjectController = TextEditingController();
  String? _selectedDay;
  int? _selectedClassId;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<dynamic> _classes = [];

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  @override
  void initState() {
    super.initState();
    _fetchClasses(); // Memanggil fungsi untuk mengambil daftar kelas dari backend
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil daftar kelas dari backend
  Future<void> _fetchClasses() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.3/absensi/api/api_get_jadwal_kelas.php')); // Sesuaikan URL Anda

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            _classes = data['data']; // Asumsikan data kelas berada di key 'data'
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data kelas tidak ditemukan."), backgroundColor: Colors.orange),
          );
        }
      } else {
        throw Exception("Gagal mengambil data kelas dari server.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  // Fungsi untuk menyimpan jadwal
  void _saveSchedule() async {
    if (_formKey.currentState!.validate() &&
        _selectedDay != null &&
        _startTime != null &&
        _endTime != null &&
        _selectedClassId != null) {
      String subject = _subjectController.text.trim();
      String day = _selectedDay!;
      String startTime = _startTime!.format(context);
      String endTime = _endTime!.format(context);

      // ID pengguna di sini hanya sebagai contoh
      int userId = 1; // Ganti dengan ID pengguna sebenarnya

      String url = "http://172.20.10.3/absensi/api/api_tambah_jadwal.php"; // Sesuaikan URL Anda

      // Data yang akan dikirim ke backend
      Map<String, dynamic> scheduleData = {
        "user_id": userId,
        "mata_pelajaran": subject,
        "hari": day,
        "waktu_mulai": startTime,
        "waktu_selesai": endTime,
        "kelas_id": _selectedClassId,
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(scheduleData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          if (responseData['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message']), backgroundColor: Colors.green),
            );

            _subjectController.clear();
            setState(() {
              _selectedDay = null;
              _selectedClassId = null;
              _startTime = null;
              _endTime = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message']), backgroundColor: Colors.red),
            );
          }
        } else {
          throw Exception("Gagal menyimpan data. Status code: ${response.statusCode}");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua data sebelum menyimpan!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
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
                Text('Form Tambah Jadwal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                SizedBox(height: 16),
                // Input Mata Pelajaran
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Nama Mata Pelajaran',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama mata pelajaran tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Pilihan Kelas dari Database
                DropdownButtonFormField<int>(
                  value: _selectedClassId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Kelas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_),
                  ),
                  items: _classes.map<DropdownMenuItem<int>>((kelas) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(kelas['id'].toString()), // Pastikan 'id' menjadi int
                      child: Text(kelas['nama_kelas']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kelas';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Pilihan Hari
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: InputDecoration(
                    labelText: 'Hari',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: _days.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih hari';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Pilihan Jam Mulai
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text(
                    _startTime == null
                        ? 'Pilih Jam Mulai'
                        : 'Jam Mulai: ${_startTime!.format(context)}',
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectStartTime(context),
                ),
                Divider(),
                // Pilihan Jam Berakhir
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text(
                    _endTime == null
                        ? 'Pilih Jam Berakhir'
                        : 'Jam Berakhir: ${_endTime!.format(context)}',
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectEndTime(context),
                ),
                Divider(),
                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSchedule,
                    child: Text('Simpan Jadwal', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.blueAccent,
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
