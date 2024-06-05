import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomingCallPage extends StatefulWidget {
  final String callerName;
  const IncomingCallPage({super.key, required this.callerName});

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage> {
  final player = AudioPlayer();
  bool _callPicked = false;

  @override
  void initState() {
    super.initState();
    _playRingtone();
  }

  Future<void> _playRingtone() async {
    try {
      await player.play(
        AssetSource('ringtone.mp3'),
      );
      player.setReleaseMode(ReleaseMode.loop);
      print('Audio playing');
    } catch (e) {
      print('Error playing ringtone: $e');
    }
  }

  Future<void> _stopRingtone() async {
    try {
      await player.stop();
      print('Audio stopped');
      Navigator.pop(context);
    } catch (e) {
      print('Error stopping ringtone: $e');
    }
  }

  void _pickCall() {
    setState(() {
      _callPicked = true;
    });
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Call from',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 16),
                  ),
                  Text(
                    widget.callerName == '' ? 'Tarun' : widget.callerName,
                    style: GoogleFonts.dmSans(fontSize: 40),
                  ),
                  Text(
                    'Mobile',
                    style: GoogleFonts.dmSans(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _stopRingtone,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(30),
                    backgroundColor: Colors.red,
                  ),
                  child: const Icon(
                    Icons.call_end_outlined,
                    color: Colors.white,
                  ),
                ),
                if (_callPicked == false)
                  ElevatedButton(
                    onPressed: _pickCall,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(30),
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.call_outlined,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
