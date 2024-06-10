// ignore_for_file: prefer_const_constructors, use_full_hex_values_for_flutter_colors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackingapp/components/input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPassTextController = TextEditingController();

  void signUp() async {
    try {
      if (passwordTextController.text == confirmPassTextController.text) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailTextController.text,
                password: passwordTextController.text);

        User? user = userCredential.user;
        String userId = user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'userId': userId,
          'fullName': nameTextController.text,
          'email': emailTextController.text,
          'profilePicture':
              'https://firebasestorage.googleapis.com/v0/b/trackingapp-3fedb.appspot.com/o/placeholder-image.jpg?alt=media&token=fc0def48-dbbf-4080-b05d-cb823390ab02'
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final height = MediaQuery.of(context).size.height * 1;
    // final width = MediaQuery.of(context).size.width * 1;

    return Scaffold(
      // backgroundColor: Color(0xFFFFFFE5),
      backgroundColor: Color(0xffF0CF69),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/image1.png',
              fit: BoxFit.cover,
              height: height * 0.5,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.5,
                  width: double.infinity,
                ),
                Container(
                  height: height * 0.75,
                  decoration: BoxDecoration(
                    // color: Color(0xFFFFFFE5),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Tracking',
                        style: GoogleFonts.dmSans(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appLocalizations.signupActionText,
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MyInputField(
                        hintText: appLocalizations.signupNamePlaceholder,
                        prefixIcon: Icons.person,
                        controller: nameTextController,
                      ),
                      MyInputField(
                        hintText: appLocalizations.signupEmailPlaceholder,
                        prefixIcon: Icons.email,
                        controller: emailTextController,
                      ),
                      MyInputField(
                        hintText: appLocalizations.signupPasswordPlaceholder,
                        prefixIcon: Icons.lock,
                        controller: passwordTextController,
                        isPassword: true,
                      ),
                      MyInputField(
                        hintText:
                            appLocalizations.signupConfirmPasswordPlaceholder,
                        prefixIcon: Icons.lock,
                        controller: confirmPassTextController,
                        isPassword: true,
                      ),
                      ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          // backgroundColor: Color(0xFFFFD373),
                          backgroundColor: Color(0xFF1D0C2C),
                          padding: EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 20,
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          appLocalizations.signupButton,
                          style: GoogleFonts.dmSans(color: Colors.white),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appLocalizations.signupBottomText,
                            style: GoogleFonts.dmSans(),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              appLocalizations.signupBottomTextTwo,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
