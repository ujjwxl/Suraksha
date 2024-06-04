import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackingapp/components/input_field.dart';
import 'package:trackingapp/pages/incoming_call_page.dart';

class FakeCallPage extends StatefulWidget {
  const FakeCallPage({super.key});

  @override
  State<FakeCallPage> createState() => _FakeCallPageState();
}

class _FakeCallPageState extends State<FakeCallPage> {
  final List<int> possibleTimes = [0, 3, 5, 10, 30, 60, 120];
  int _selectedTime = 0;
  int _remainingSeconds = 0;
  late Timer _timer;

  final TextEditingController _callerNameController = TextEditingController();

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _remainingSeconds = _selectedTime;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(
          () {
            if (_remainingSeconds > 0) {
              _remainingSeconds--;
            } else {
              timer.cancel();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncomingCallPage(),
                ),
              );
            }
          },
        );
      },
    );
  }

  void cancelTimer() {
    _timer.cancel();
    setState(() {
      _remainingSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fake Call',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Call me in',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: possibleTimes.length,
                  itemBuilder: (context, index) {
                    final isSelected = possibleTimes[index] == _selectedTime;
                    final color = isSelected
                        ? const Color(0xFF1D0C2C)
                        : Colors.transparent;
                    final textColor = isSelected ? Colors.white : Colors.black;
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedTime = possibleTimes[index];
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(color),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xFF1D0C2C)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: Text(
                          '${possibleTimes[index]} sec',
                          style: GoogleFonts.dmSans(
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 5,
                  right: 5,
                ),
                child: TextField(
                  controller: _callerNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: 'Add a caller name',
                    hintStyle: GoogleFonts.dmSans(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5.0),
                child: ElevatedButton(
                  onPressed: () {
                    startTimer();
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                        10.0,
                      )),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFF1D0C2C)),
                    padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
                  ),
                  child: Text(
                    'Call Me',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Column(
              children: [
                Text(_remainingSeconds != 0 ? 'Calling in' : ''),
                Text(
                  _remainingSeconds != 0 ? '$_remainingSeconds' : '',
                  style: GoogleFonts.dmSans(
                    fontSize: 64,
                  ),
                ),
              ],
            ),
          ),
          if (_remainingSeconds > 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
              child: ElevatedButton(
                onPressed: () {
                  cancelTimer();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20.0)),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
