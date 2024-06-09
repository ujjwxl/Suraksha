import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackingapp/auth/auth.dart';
import 'package:trackingapp/data/onboarding_data.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  PageController? _controller;
  int currentIndex = 0;
  double percentage = 0.33;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: contentsList[currentIndex].backgroundColor,
        title: Text(
          'Hello',
          style: TextStyle(color: contentsList[currentIndex].backgroundColor),
        ),
      ),
      backgroundColor: contentsList[currentIndex].backgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: PageView.builder(
              controller: _controller,
              itemCount: contentsList.length,
              onPageChanged: (int index) {
                if (index >= currentIndex) {
                  setState(() {
                    currentIndex = index;
                    percentage += 0.33;
                  });
                } else {
                  setState(() {
                    currentIndex = index;
                    percentage -= 0.33;
                  });
                }
              },
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            contentsList[index].title,
                            style: GoogleFonts.dmSans(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            contentsList[index].description,
                            style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Image.asset(
                          contentsList[index].image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: List.generate(contentsList.length,
                            (index) => buildDot(index, context)),
                      ),
                      // CupertinoButton(
                      //   onPressed: () {},
                      //   child: Text(
                      //     'Skip',
                      //     style: GoogleFonts.dmSans(),
                      //   ),
                      // )
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      if (currentIndex == contentsList.length - 1) {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('showHome', true);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const AuthPage(),
                          ),
                        );
                      }
                      _controller!.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 55,
                          width: 55,
                          child: CircularProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.white38,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: contentsList[currentIndex].backgroundColor,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  AnimatedContainer buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 500),
      curve: Curves.easeInOut,
      height: 8,
      width: currentIndex == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: currentIndex == index ? Colors.white : Colors.white38,
      ),
    );
  }
}
