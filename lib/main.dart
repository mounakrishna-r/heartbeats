import 'package:flutter/material.dart';
import 'package:health/health.dart';

void main() => runApp( MaterialApp( home: HeartRateStream()));

class HeartRateStream extends StatefulWidget{

  const HeartRateStream({super.key});

  @override
  State <HeartRateStream> createState() => _HeartRateStreamState();
}

class _HeartRateStreamState extends State<HeartRateStream>{
  final HealthFactory _health = HealthFactory();
  int? _bpm;
  bool _authorized = false;

  Future<void> fetchBPM() async{
    final types = [HealthDataType.HEART_RATE];
    final now = DateTime.now();
    final past = now.subtract(Duration(minutes: 2));

    _authorized = await _health.requestAuthorization(types);

    if(_authorized){
      final data = await _health.getHealthDataFromTypes(past, now, types);
      if(data.isNotEmpty){
        final latest = data.last;
        setState(() {
          _bpm = (latest.value as NumericHealthValue).numericValue.round();});
      }
    } else{
      print('X not authorized');
    }
  }

  @override
  void initState(){
    super.initState();
    fetchBPM();
    Future.delayed(Duration.zero, () async{
      while(mounted) {
        await fetchBPM();
        await Future.delayed(Duration(seconds: 10));
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Live Heart Rate")),
      body: Center(
        child: Text(
          _bpm !=null ? 'BPM: $_bpm' : 'waiting for data....',
          style: TextStyle(fontSize: 32),
        ),
      )
    );
  }
}