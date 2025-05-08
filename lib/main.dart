import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:heartbeats/services/heartRateService.dart';

void main() => runApp(const HeartbeatsApp());

class HeartbeatsApp extends StatelessWidget{
  const HeartbeatsApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Heartbeats',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HeartRateStream(),
    );
  }
}

class HeartRateStream extends StatefulWidget{

  const HeartRateStream({super.key});

  @override
  State <HeartRateStream> createState() => _HeartRateStreamState();
}

class _HeartRateStreamState extends State<HeartRateStream>{
  final HeartRateService _service = HeartRateService();
  int? _bpm;
  String _suggestedTrack = 'Waiting for the track..';
  late final Timer _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final bpm = await _service.fetchLatestBPM();
      if (bpm != null) {
        setState(() {
          _bpm = bpm;
          _suggestedTrack = _service.pickTrackLabelFromBPM(bpm);
        });
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final bpmText = _bpm != null ? '$_bpm BPM' : 'waiting for BPM...';

    return Scaffold(
      appBar: AppBar(title: const Text('Live Heart Rate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 72)
                .animate(onPlay: (controller) => controller.repeat())
                .scaleXY(duration: 600.ms, begin: 1, end: 1.2)
                .then()
                .scaleXY(duration: 600.ms, begin: 1.2, end: 1),
            const SizedBox(height: 30),
            
            Text(
              bpmText,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Live from Apple watch',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600]),
            ),

              const SizedBox(height: 40),

              const Divider(thickness: 1),

              const SizedBox(height: 20),

              Text(
                'Suggested Track:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              Text(
                _suggestedTrack,
                style: const TextStyle(fontSize: 22, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}