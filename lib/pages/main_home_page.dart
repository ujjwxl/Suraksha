import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

    String userId = FirebaseAuth.instance.currentUser!.uid;

    DateTime now = DateTime.now();

    CollectionReference trackingCollection =
        FirebaseFirestore.instance.collection('tracking');

    trackingCollection.doc(userId).set({
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'updatedAt': now
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

      DateTime now = DateTime.now();

      trackingCollection.doc(userId).set({
        'from': _fromController.text,
        'to': _toController.text,
        'license': _licenseController.text,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'updatedAt': now
      });
    });
  }

  void _showModalBottomSheet(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            top: 20.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appLocalizations.homeTrackingModalHeading,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                style: GoogleFonts.dmSans(fontSize: 16),
                controller: _fromController,
                decoration: InputDecoration(
                  labelText: appLocalizations.homeTrackingFrom,
                  labelStyle: GoogleFonts.dmSans(fontSize: 14),
                ),
              ),
              TextField(
                style: GoogleFonts.dmSans(fontSize: 16),
                controller: _toController,
                decoration: InputDecoration(
                  labelText: appLocalizations.homeTrackingTo,
                  labelStyle: GoogleFonts.dmSans(fontSize: 14),
                ),
              ),
              TextField(
                style: GoogleFonts.dmSans(fontSize: 16),
                controller: _licenseController,
                decoration: InputDecoration(
                  labelText: appLocalizations.homeTrackingLicenseNumber,
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
                child: Text(appLocalizations.homeTrackingButton,
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.homeAppBarTitle,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showModalBottomSheet(context);
            },
            icon: const Icon(Icons.navigation_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
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
          if (_trackingStarted)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.02,
              left: MediaQuery.of(context).size.width * 0.5 - 100,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Text(
                      appLocalizations.homeTrackingEnabledHeading,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appLocalizations.homeTrackingEnabledSubtitle,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
