import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class IncomingCallPage extends StatefulWidget {
  const IncomingCallPage({super.key});

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage> {
  final player = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Incoming call page'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopRingtone,
              child: Text('Stop Ringtone'),
            ),
          ],
        ),
      ),
    );
  }
}
