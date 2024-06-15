import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trackingapp/pages/location_details_page.dart';
import 'package:trackingapp/pages/sos_details_page.dart';
import 'package:transparent_image/transparent_image.dart';

class AllSOSPage extends StatefulWidget {
  const AllSOSPage({super.key});

  @override
  State<AllSOSPage> createState() => _AllSOSPageState();
}

class _AllSOSPageState extends State<AllSOSPage> {
  List<String> _members = [];
  List<Map<String, dynamic>> _allSOS = [];
  bool _isLoading = true;

  Future<void> _fetchGroupMembers() async {
    final String myUserId = FirebaseAuth.instance.currentUser!.uid;
    final myDocSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(myUserId)
        .get();

    setState(() {
      _members = List<String>.from(myDocSnapshot['members'] ?? []);
    });

    print("Got all members");
    print(_members);

    await _fetchAllSOS();
  }

  // Future<void> _fetchAllSOS() async {
  //   print("Starting to get all sos function");
  //   List<Map<String, dynamic>> allSOS = [];

  //   for (String memberId in _members) {
  //     print(memberId);
  //     final memberDocSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(memberId)
  //         .get();

  //     List<dynamic> memberSOS = memberDocSnapshot['sos'] ?? [];
  //     String fullName = memberDocSnapshot['fullName'];
  //     String profilePicture = memberDocSnapshot['profilePicture'];

  //     print(memberSOS);

  //     for (var sos in memberSOS) {
  //       Map<String, dynamic> sosWithInfo = Map.from(sos);
  //       sosWithInfo['fullName'] = fullName;
  //       sosWithInfo['profilePicture'] = profilePicture;
  //       allSOS.add(sosWithInfo);
  //     }
  //   }

  //   print(allSOS);

  //   allSOS.sort((a, b) => b['time'].compareTo(a['time']));

  //   setState(() {
  //     _allSOS = allSOS;
  //   });

  //   print(allSOS);
  // }

  Future<void> _fetchAllSOS() async {
    List<Map<String, dynamic>> allSOS = [];

    try {
      for (String memberId in _members) {
        // if (memberId.isEmpty) continue;

        final memberDocSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        if (memberDocSnapshot.exists) {
          // Check if 'sos' field exists and is not null
          if (memberDocSnapshot.data()!.containsKey('sos') &&
              memberDocSnapshot['sos'] != null) {
            List<dynamic> memberSOS = memberDocSnapshot['sos'];

            String fullName = memberDocSnapshot['fullName'] ?? '';
            String profilePicture = memberDocSnapshot['profilePicture'] ?? '';

            for (var sos in memberSOS) {
              Map<String, dynamic> sosWithInfo = Map.from(sos);
              sosWithInfo['fullName'] = fullName;
              sosWithInfo['profilePicture'] = profilePicture;

              Timestamp timestamp = sos['time'];
              sosWithInfo['time'] = timestamp.toDate();

              allSOS.add(sosWithInfo);
            }
          } else {
            print('No SOS data found for memberId $memberId');
          }
        } else {
          print('Document for memberId $memberId does not exist.');
        }
      }

      allSOS.sort((a, b) => b['time'].compareTo(a['time']));

      setState(() {
        _allSOS = allSOS;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching SOS: $e');
    }
  }

  String formattedDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat("dd MMMM yyyy 'at' hh:mm a");
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _fetchGroupMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All SOS',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _allSOS.isEmpty
              ? const Center(
                  child: Text('No SOS found'),
                )
              : ListView.builder(
                  itemCount: _allSOS.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: Colors.grey[300] ?? Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SOSDetailsPage(
                                  sosInfo: _allSOS[index],
                                ),
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: _allSOS[index]['profilePicture'],
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            _allSOS[index]['fullName'],
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            formattedDate(_allSOS[index]['time']),
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
