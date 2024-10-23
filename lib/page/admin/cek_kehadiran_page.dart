import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CekKehadiranPage extends StatefulWidget {
  @override
  _CekKehadiranPageState createState() => _CekKehadiranPageState();
}

class _CekKehadiranPageState extends State<CekKehadiranPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  DateTime? _selectedDate;
  List<dynamic> attendanceSchoolReports = [];
  List<dynamic> attendanceClassReports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAttendanceReports();
    _fetchAttendanceClassReports();
  }

  Future<void> _fetchAttendanceReports() async {
    String url = "http://172.20.10.3/absensi/api/api_get_laporan.php";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          attendanceSchoolReports = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil laporan kehadiran sekolah.");
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

  Future<void> _fetchAttendanceClassReports() async {
    String url =
        "http://172.20.10.3/absensi/api/api_get_laporan_absensi_kelas.php";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          attendanceClassReports =
              json.decode(response.body)['laporan_absensi_kelas'];
          isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil laporan kehadiran kelas.");
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

  List<dynamic> getFilteredReports(List<dynamic> reports) {
    if (_selectedDate == null) {
      return reports;
    }
    String selectedDateStr = _selectedDate!.toIso8601String().split('T')[0];
    return reports.where((report) {
      return report.containsKey('waktu_absen')
          ? report['waktu_absen'].split(' ')[0] == selectedDateStr
          : report['tanggal'] == selectedDateStr;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSchoolReports =
        getFilteredReports(attendanceSchoolReports);
    List<dynamic> filteredClassReports =
        getFilteredReports(attendanceClassReports);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cek Kehadiran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Absensi Kelas'),
            Tab(text: 'Absensi Sekolah'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.blueAccent,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Semua Tanggal'
                            : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text('Pilih Tanggal'),
                        style: ElevatedButton.styleFrom(
                          iconColor: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        filteredClassReports.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada data absensi kelas untuk tanggal yang dipilih.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : _buildReportList(filteredClassReports),
                        filteredSchoolReports.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada data absensi sekolah untuk tanggal yang dipilih.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : _buildReportList(filteredSchoolReports),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Fungsi untuk membangun tampilan ListView dari laporan
  Widget _buildReportList(List<dynamic> reports) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        var report = reports[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                report['nama']?[0] ??
                    report['mata_pelajaran'][
                        0], // Periksa apakah report punya nama atau mata pelajaran
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              report['nama'] ??
                  report[
                      'mata_pelajaran'], // Tampilkan nama atau mata pelajaran
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.containsKey('nip_ngta'))
                  Text("NIP/Ngta: ${report['nip_ngta']}"),
                if (report.containsKey('waktu_absen'))
                  Text("Waktu: ${report['waktu_absen']}"),
                Text("Status: ${report['status']}"),
              ],
            ),
            trailing: Icon(
              _getStatusIcon(report['status']),
              color: _getStatusColor(report['status']),
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk mendapatkan ikon status kehadiran
  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Hadir":
        return Icons.check_circle;
      case "Izin":
        return Icons.info;
      case "Terlambat":
        return Icons.access_time;
      case "Alpa":
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Fungsi untuk mendapatkan warna status kehadiran
  Color _getStatusColor(String status) {
    switch (status) {
      case "Hadir":
        return Colors.green;
      case "Izin":
        return Colors.orange;
      case "Terlambat":
        return Colors.redAccent;
      case "Alpa":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
