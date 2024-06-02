import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  late LatLng _currentLocation;
  bool _permissionGranted = false;
  bool _trackingStarted = false;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _permissionGranted = true;
    });

    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  Future<void> _startTracking() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference trackingCollection =
        FirebaseFirestore.instance.collection('tracking');

    Location location = Location();
    location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
      location.enableBackgroundMode(enable: true);

      trackingCollection.doc(userId).set({
        'from': _fromController.text,
        'to': _toController.text,
        'license': _licenseController.text,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
      });
    });
  }

  void _showModalBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Summary',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                style: GoogleFonts.dmSans(fontSize: 16),
                controller: _fromController,
                decoration: InputDecoration(
                  labelText: 'From',
                  labelStyle: GoogleFonts.dmSans(fontSize: 14),
                ),
              ),
              TextField(
                style: GoogleFonts.dmSans(fontSize: 16),
                controller: _toController,
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: GoogleFonts.dmSans(fontSize: 14),
                ),
              ),
              TextField(
                style: GoogleFonts.dmSans(fontSize: 16),
                controller: _licenseController,
                decoration: InputDecoration(
                  labelText: 'License Number',
                  labelStyle: GoogleFonts.dmSans(fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _trackingStarted = true;
                  });
                  _startTracking();
                  Navigator.pop(context); // Close the bottom sheet
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF1D0C2C)),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
                ),
                child: Text('Start Tracking',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showModalBottomSheet();
            },
            icon: const Icon(Icons.navigation_outlined),
          ),
        ],
      ),
      body: Center(
        child: _permissionGranted
            ? FlutterMap(
                options: MapOptions(
                  initialCenter: _currentLocation,
                  initialZoom: 17.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        // 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        'https://maps.geoapify.com/v1/tile/osm-liberty/{z}/{x}/{y}.png?apiKey=790915664d99474e8ad53d13fbbd9484',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation,
                        width: 250,
                        height: 250,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            // ? Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       const Text(
            //         'Current Location:',
            //       ),
            //       Text(
            //         'Latitude: ${_currentLocation.latitude}',
            //       ),
            //       Text(
            //         'Longitude: ${_currentLocation.longitude}',
            //       ),
            //     ],
            //   )
            : const Text('Permission not granted'),
      ),
    );
  }
}
