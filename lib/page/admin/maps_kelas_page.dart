import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapsPage extends StatefulWidget {
  final LatLng initialLocation;

  MapsPage({required this.initialLocation});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(-7.250445, 112.768845);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Lokasi Kelas'),
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari lokasi...',
                  border: InputBorder.none,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.blueAccent),
                        onPressed: _searchLocation,
                      ),
                    ],
                  ),
                ),
                onSubmitted: (value) {
                  _searchLocation();
                },
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('selectedLocation'),
                  position: _selectedLocation,
                ),
              },
              onTap: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedLocation);
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    try {
      if (query.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Masukkan kata kunci untuk pencarian.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location firstLocation = locations.first;
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(firstLocation.latitude, firstLocation.longitude),
            zoom: 14.0,
          ),
        ));
        setState(() {
          _selectedLocation =
              LatLng(firstLocation.latitude, firstLocation.longitude);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lokasi tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
