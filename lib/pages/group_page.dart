import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackingapp/pages/location_details_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:transparent_image/transparent_image.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  DocumentSnapshot<Map<String, dynamic>>? _userSnapshot;
  List<String> _members = [];

  Future<void> _searchUser(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      setState(() {
        _userSnapshot = snapshot;
      });
    } catch (e) {
      print(e);

      // Handle error
    }
  }

  void _addUserToGroup(BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    try {
      final String myUserId = FirebaseAuth.instance.currentUser!.uid;
      final String shownUserId = _userSnapshot!.id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(myUserId)
          .update({
        'members': FieldValue.arrayUnion([shownUserId]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(shownUserId)
          .update({
        'members': FieldValue.arrayUnion([myUserId]),
      });

      _fetchGroupMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.groupSnackBarSuccess),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.groupSnackBarError),
        ),
      );
    }
  }

  Future<void> _fetchGroupMembers() async {
    final String myUserId = FirebaseAuth.instance.currentUser!.uid;
    final myDocSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(myUserId)
        .get();

    setState(() {
      _members = List<String>.from(myDocSnapshot['members'] ?? []);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchGroupMembers();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.groupAppBarTitle,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: appLocalizations.groupUserSearchHintText,
              onSubmitted: (value) {
                _searchUser(value);
              },
              hintStyle: MaterialStateProperty.all(
                GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              textStyle: MaterialStateProperty.all(
                GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              elevation: MaterialStateProperty.all(0.0),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          if (_userSnapshot != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  // color: Colors.grey[200],
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.grey[300] ?? Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: _userSnapshot!['profilePicture'],
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              _userSnapshot!['fullName'],
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _addUserToGroup(context);
                          },
                          child: const Icon(Icons.group_add),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Text(
            appLocalizations.groupMembersTitle,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_members[index])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final memberSnapshot = snapshot.data!;
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
                                builder: (context) => LocationDetailsPage(
                                    userId: _members[index]),
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: memberSnapshot['profilePicture'],
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            memberSnapshot['fullName'],
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
