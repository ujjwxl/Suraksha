import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackingapp/models/sos_model.dart';
import 'package:trackingapp/pages/all_sos_page.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  late LatLng _currentLocation;
  bool _permissionGranted = false;
  bool _isTimerRunning = false;
  int _timerCount = 3;
  late Timer _timer;
  Color _buttonColor = const Color(0xffD00606);

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

    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    SOSData sosData = SOSData(
      latitude: locationData.latitude!,
      longitude: locationData.longitude!,
      time: DateTime.now(),
    );

    usersCollection.doc(userId).update({
      'sos': FieldValue.arrayUnion([sosData.toJson()])
    });
  }

  void startTimer() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCount > 0) {
          HapticFeedback.heavyImpact();
          _timerCount--;
        } else {
          HapticFeedback.heavyImpact();
          _getLocation();
          _isTimerRunning = false;
          _timerCount = 3;
          timer.cancel();
        }
      });
    });
  }

  void stopTimer() {
    _timer.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isTimerRunning = false;
      _timerCount = 3;
      _buttonColor = const Color(0xffD00606);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SOS',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllSOSPage(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'An alert will be sent to your members with your location',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Text(
              _isTimerRunning ? 'Alert sending in' : '',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              if (!_isTimerRunning) {
                startTimer();
                setState(() {
                  _buttonColor = Colors.red;
                });
              } else {
                stopTimer();
              }
            },
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _isTimerRunning ? 150 : 200,
                height: _isTimerRunning ? 150 : 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _buttonColor,
                ),
                child: Center(
                  child: Text(
                    _isTimerRunning ? '$_timerCount' : 'SOS',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Text(
              _isTimerRunning ? 'Press again to CANCEL' : '',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
