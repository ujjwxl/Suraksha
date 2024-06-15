import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class SOSDetailsPage extends StatelessWidget {
  final Map<String, dynamic> sosInfo;
  const SOSDetailsPage({super.key, required this.sosInfo});

  @override
  Widget build(BuildContext context) {
    print(sosInfo);

    final latitude = sosInfo['latitude'];
    final longitude = sosInfo['longitude'];
    final LatLng _currentLocation = LatLng(latitude ?? 0.0, longitude ?? 0.0);

    String formattedDate(DateTime dateTime) {
      final DateFormat formatter = DateFormat("dd MMMM yyyy 'at' hh:mm a");
      return formatter.format(dateTime);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'SOS Details',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            FlutterMap(
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
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.02,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formattedDate(sosInfo['time']),
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
