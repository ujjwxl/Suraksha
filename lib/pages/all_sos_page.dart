import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllSOSPage extends StatefulWidget {
  const AllSOSPage({super.key});

  @override
  State<AllSOSPage> createState() => _AllSOSPageState();
}

class _AllSOSPageState extends State<AllSOSPage> {
  List<String> _members = [];
  List<Map<String, dynamic>> _allSOS = [];

  Future<void> _fetchGroupMembers() async {
    final String myUserId = FirebaseAuth.instance.currentUser!.uid;
    final myDocSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(myUserId)
        .get();

    setState(() {
      _members = List<String>.from(myDocSnapshot['members'] ?? []);
    });

    print(_members);

    await _fetchAllSOS();
  }

  Future<void> _fetchAllSOS() async {
    List<Map<String, dynamic>> allSOS = [];

    for (String memberId in _members) {
      final memberDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .get();

      List<dynamic> memberSOS = memberDocSnapshot['sos'] ?? [];
      String fullName = memberDocSnapshot['fullName'];
      String profilePicture = memberDocSnapshot['profilePicture'];

      print(memberSOS);

      for (var sos in memberSOS) {
        Map<String, dynamic> sosWithInfo = Map.from(sos);
        sosWithInfo['fullName'] = fullName;
        sosWithInfo['profilePicture'] = profilePicture;
        allSOS.add(sosWithInfo);
      }
    }

    print(allSOS);

    allSOS.sort((a, b) => b['time'].compareTo(a['time']));

    setState(() {
      _allSOS = allSOS;
    });

    print(allSOS);
  }

  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();
      _fetchGroupMembers();
    }

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
      body: _allSOS.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allSOS.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'SOS ${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time: ${_allSOS[index]['time']}',
                      ),
                      Text(
                        'Full Name: ${_allSOS[index]['fullName']}',
                      ),
                      Image.network(
                        _allSOS[index]['profilePicture'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
