import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  late LatLng _currentLocation;
  bool _permissionGranted = false;
  bool _trackingStarted = false;

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
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _trackingStarted = true;
              });
              _startTracking();
            },
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Center(
        child: _permissionGranted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Current Location:',
                  ),
                  Text(
                    'Latitude: ${_currentLocation.latitude}',
                  ),
                  Text(
                    'Longitude: ${_currentLocation.longitude}',
                  ),
                ],
              )
            : const Text('Permission not granted'),
      ),
    );
  }
}
