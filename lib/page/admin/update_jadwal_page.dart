import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateJadwalPage extends StatefulWidget {
  final Map<String, dynamic> jadwalData;

  UpdateJadwalPage({required this.jadwalData, required jadwal});

  @override
  _UpdateJadwalPageState createState() => _UpdateJadwalPageState();
}

class _UpdateJadwalPageState extends State<UpdateJadwalPage> {
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
    _fetchClasses();
    _loadJadwalData();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _loadJadwalData() {
    setState(() {
      _subjectController.text = widget.jadwalData['mata_pelajaran'];
      _selectedDay = widget.jadwalData['hari'];
      _startTime = TimeOfDay(
          hour: int.parse(widget.jadwalData['waktu_mulai'].split(':')[0]),
          minute: int.parse(widget.jadwalData['waktu_mulai'].split(':')[1]));
      _endTime = TimeOfDay(
          hour: int.parse(widget.jadwalData['waktu_selesai'].split(':')[0]),
          minute: int.parse(widget.jadwalData['waktu_selesai'].split(':')[1]));
      _selectedClassId = int.parse(widget.jadwalData['kelas_id']);
    });
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.3/absensi/api/api_get_kelas.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _classes = data['data'];
        });
      } else {
        throw Exception("Gagal mengambil data kelas.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateJadwal() async {
    if (_formKey.currentState!.validate() &&
        _selectedDay != null &&
        _startTime != null &&
        _endTime != null &&
        _selectedClassId != null) {
      String subject = _subjectController.text.trim();
      String day = _selectedDay!;
      String startTime = _startTime!.format(context);
      String endTime = _endTime!.format(context);
      int jadwalId = widget.jadwalData['id'];
      int userId = 1; // Replace with actual user ID

      String url = "http://192.168.1.21/absensi/api/api_update_jadwal.php";

      Map<String, dynamic> scheduleData = {
        "id": jadwalId,
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

            Navigator.pop(context, true); // Return to the previous page and refresh
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message']), backgroundColor: Colors.red),
            );
          }
        } else {
          throw Exception("Gagal memperbarui data. Status code: ${response.statusCode}");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
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
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
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
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Nama Mata Pelajaran',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama mata pelajaran tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<int>(
                  value: _selectedClassId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Kelas',
                    border: OutlineInputBorder(),
                  ),
                  items: _classes.map<DropdownMenuItem<int>>((kelas) {
                    return DropdownMenuItem<int>(
                      value: int.parse(kelas['id'].toString()),
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
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: InputDecoration(
                    labelText: 'Hari',
                    border: OutlineInputBorder(),
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
                ListTile(
                  title: Text(_startTime == null ? 'Pilih Jam Mulai' : 'Jam Mulai: ${_startTime!.format(context)}'),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectStartTime(context),
                ),
                ListTile(
                  title: Text(_endTime == null ? 'Pilih Jam Berakhir' : 'Jam Berakhir: ${_endTime!.format(context)}'),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectEndTime(context),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateJadwal,
                    child: Text('Update Jadwal', style: TextStyle(fontSize: 16)),
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
