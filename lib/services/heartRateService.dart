import 'package:flutter/cupertino.dart';
import 'package:health/health.dart';

class HeartRateService {
  final HealthFactory _health = HealthFactory();

  /// Pulls the latest heart rate reading from HealthKit (iOS).
  Future<int?> fetchLatestBPM() async {
    final List<HealthDataType>types = [HealthDataType.HEART_RATE];
    final Duration queryWindow = Duration(minutes: 3);
    final now = DateTime.now();
    final past = now.subtract(const Duration(minutes: 3));

    final authorized = await _health.requestAuthorization(types);
    if (!authorized) {
      debugPrint('❌ HealthKit access not authorized.');
      return null;
    }

    final data = await _health.getHealthDataFromTypes(past, now, types);
    if (data.isEmpty) {
      print('❌ No heart rate data found.');
      return null;
    }

    final latest = data.last;
    return (latest.value as NumericHealthValue).numericValue.round();
  }

  /// Suggests a song/genre for the given heart rate.
  String pickTrackLabelFromBPM(int bpm) {
    if (bpm < 70) return 'Lo-fi Chill – unwind ✨';
    if (bpm < 90) return 'Indie Grooves – smooth flow 🌊';
    if (bpm < 110) return 'Dance Pop – move your vibe 🎶';
    if (bpm < 130) return 'EDM Pulse – let it lift 🔥';
    return 'Hard Beats – unleash beast mode ⚡️';
  }

}