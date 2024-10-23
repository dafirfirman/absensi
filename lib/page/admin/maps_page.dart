import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapsPage extends StatefulWidget {
  final LatLng initialPosition;

  const MapsPage({required this.initialPosition});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController _controller;
  LatLng? _pickedLocation;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isMapCreated = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPosition;
    _isLoading = false;
  }

  void _onCameraMove(CameraPosition position) {
    _pickedLocation = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _isMapCreated = true;
    });
  }

  void _onPickLocation() {
    if (_pickedLocation != null) {
      Navigator.pop(context, _pickedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih lokasi absensi terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    try {
      if (query.isEmpty) {
        throw Exception("Kata kunci pencarian tidak boleh kosong");
      }
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location firstLocation = locations.first;
        _controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(firstLocation.latitude, firstLocation.longitude),
            zoom: 15,
          ),
        ));
        setState(() {
          _pickedLocation =
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

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 152, 202),
        title: Text(
          'Pilih Lokasi Absensi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _onPickLocation,
            child: Text(
              'Simpan',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.initialPosition,
                    zoom: 15,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                ),
                if (!_isMapCreated) Center(child: CircularProgressIndicator()),
                Center(
                  child: Icon(
                    Icons.location_on,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 15,
                  right: 15,
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi absensi...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: _clearSearch,
                                ),
                                IconButton(
                                  icon: Icon(Icons.search,
                                      color: Colors.blueAccent),
                                  onPressed: _searchLocation,
                                ),
                              ],
                            )
                          : IconButton(
                              icon:
                                  Icon(Icons.search, color: Colors.blueAccent),
                              onPressed: _searchLocation,
                            ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: (value) {
                      _searchLocation();
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
