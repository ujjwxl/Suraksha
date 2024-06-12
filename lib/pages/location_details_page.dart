import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:timeago/timeago.dart' as timeago;

class LocationDetailsPage extends StatelessWidget {
  final String userId;

  const LocationDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location Details',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tracking')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No data found.'),
            );
          }

          // Extract latitude and longitude from the document snapshot
          final data = snapshot.data!.data() as Map<String, dynamic>?;

          final latitude = data?['latitude'];
          final longitude = data?['longitude'];
          final from = data?['from'];
          final to = data?['to'];
          final licenseNumber = data?['license'];

          final lastUpdatedTimestamp =
              (data?['updatedAt'] as Timestamp?)?.toDate();

          final LatLng _currentLocation =
              LatLng(latitude ?? 0.0, longitude ?? 0.0);

          // Format the timestamp using timeago package
          String formattedTime = timeago
              .format(lastUpdatedTimestamp ?? DateTime.now(), locale: 'en');

          return Stack(
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
                    'Last Updated: $formattedTime',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: from != null &&
                    from.isNotEmpty &&
                    to != null &&
                    to.isNotEmpty &&
                    licenseNumber != null &&
                    licenseNumber.isNotEmpty,
                child: Positioned(
                  // top: MediaQuery.of(context).size.height * 0.02,
                  bottom: MediaQuery.of(context).size.height * 0.02,
                  left: 20,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      // color: Color(0xFF1D0C2C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Updated Trip',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'From $from to $to',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Vehicle No : $licenseNumber',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
