// ignore_for_file: sort_child_properties_last

import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackingapp/pages/change_language_page.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  late String userId;
  bool _showPreview = false;
  String _image = "images/placeholder-image.png";

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    userId = user.uid;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(
      String userId) async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Future<void> _uploadImage() async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');
      Reference referenceImageToUpload = referenceDirImages.child(userId);

      try {
        await referenceImageToUpload.putFile(File(pickedFile.path));

        String imageUrl = await referenceImageToUpload.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profilePicture': imageUrl,
        });
      } catch (e) {
        // print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Profile',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserData(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData && snapshot.data!.exists) {
              var userData = snapshot.data!.data()!;

              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    _showPreview = true;
                                    _image = userData['profilePicture'];
                                  });
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(64),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: userData['profilePicture'],
                                    width: 128,
                                    height: 128,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                child: IconButton(
                                  onPressed: _uploadImage,
                                  icon: const Icon(Icons.add_a_photo),
                                ),
                                bottom: -10,
                                left: 80,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${userData['fullName']}',
                            style: GoogleFonts.dmSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey[300] ?? Colors.transparent,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(Icons.mail_outline),
                                        Text(
                                          '${userData['email']}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person_outline),
                                        // Text(
                                        //   '${userData['userId']}',
                                        //   style: GoogleFonts.dmSans(
                                        //     fontSize: 16,
                                        //   ),
                                        // ),
                                        GestureDetector(
                                          onLongPress: () {
                                            Clipboard.setData(ClipboardData(
                                                text: '${userData['userId']}'));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Text copied to clipboard!'),
                                              ),
                                            );
                                          },
                                          child: SelectableText(
                                            '${userData['userId']}',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        Colors.grey[300] ?? Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'Change Language',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  leading: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeLanguagePage(),
                                      ),
                                    );
                                  },
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        Colors.grey[300] ?? Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'Sign Out',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                  leading: const Icon(
                                    Icons.exit_to_app,
                                    color: Colors.red,
                                  ),
                                  onTap: () {
                                    FirebaseAuth.instance.signOut();
                                    Navigator.of(context).pushNamed('/login');
                                  },
                                )),
                          )
                        ],
                      ),
                    ],
                  ),
                  if (_showPreview) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPreview = false;
                        });
                      },
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 5.0,
                          sigmaY: 5.0,
                        ),
                        child: Container(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(128),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: _image,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            } else {
              return const Center(
                child: Text('No data found.'),
              );
            }
          },
        ),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: Text('No user logged in!'),
        ),
      );
    }
  }
}
