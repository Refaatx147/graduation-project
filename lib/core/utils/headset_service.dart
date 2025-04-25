// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:mindwave_mobile2/enums/headset_state.dart';
import 'package:mindwave_mobile2/mindwave_mobile2.dart';

class MindwaveHeadsetManager {
  static final MindwaveHeadsetManager instance = MindwaveHeadsetManager._internal();
  MindwaveHeadsetManager._internal();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<HeadsetState>? _headsetStateSubscription;
  StreamSubscription<int>? _blinkSubscription;

  /// ValueNotifiers for UI
  final ValueNotifier<String> connectionStatus = ValueNotifier("🔄 جاري البحث...");
  final ValueNotifier<int?> blinkStrength = ValueNotifier(null);

  Future<void> start() async {
    connectionStatus.value = "🔍 البحث عن MindWave...";
    await FlutterBluePlus.startScan( continuousUpdates: true);

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        print ("Found device: ${result.device.name} (${result.device.id})");
        if (result.device.name.isEmpty) continue; // Skip devices with no name
        final name = result.device.localName;
        if (name == "MindWave Mobile") {
          FlutterBluePlus.stopScan();
          connectionStatus.value = "🧠 تم العثور على الجهاز";
          MindwaveMobile2.instance.init(result.device.id.id);
          _connectToDevice();
          break;
        }
      }
    });
  }

  void _connectToDevice() {
    connectionStatus.value = "🔌 جاري الاتصال...";
    MindwaveMobile2.instance.connect();

    _headsetStateSubscription = MindwaveMobile2.instance.onStateChange().listen((state) {
      if (state == HeadsetState.CONNECTED) {
        connectionStatus.value = "✅ متصل";
       
      } else if (state == HeadsetState.DISCONNECTED) {
        connectionStatus.value = "❌ غير متصل";
        MindwaveMobile2.instance.disconnect();
      } else {
        connectionStatus.value = "ℹ️ الحالة: $state";
      }
    });

    _blinkSubscription = MindwaveMobile2.instance.onBlink().listen((strength) {
      blinkStrength.value = strength;
              print('blink strength :  +${ blinkStrength.value}');

    }
    
    
    );
  }


  Future<void> dispose() async {
    await _scanSubscription?.cancel();
    await _headsetStateSubscription?.cancel();
    await _blinkSubscription?.cancel();
    await MindwaveMobile2.instance.disconnect();
  }
}



class HeadsetHomeScreen extends StatefulWidget {
  const HeadsetHomeScreen({super.key});

  @override
  State<HeadsetHomeScreen> createState() => _HeadsetHomeScreenState();
}

class _HeadsetHomeScreenState extends State<HeadsetHomeScreen> {
  final manager = MindwaveHeadsetManager.instance;
int blinkStrength=0;
  @override
  void initState() {
    super.initState();
    manager.start();
     MindwaveMobile2.instance.onBlink().listen((strength) {
          blinkStrength = strength;
        });
        print('blink strength :  +${ blinkStrength}');
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MindWave Headset"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: manager.connectionStatus,
              builder: (context, value, _) => Text(
                "🔗 الاتصال: $value",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            ValueListenableBuilder<int?>(
              valueListenable: manager.blinkStrength,
              builder: (context, value, _) => Text(
                value == null
                    ? "👁️ الرمش: لم يتم الكشف بعد"
                    : "👁️ قوة الرمش: $value",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
