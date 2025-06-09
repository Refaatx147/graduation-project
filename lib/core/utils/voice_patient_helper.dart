// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String message) async {
  //  await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage("en-US");
  //  await _tts.setSpeechRate(0.5);
    await _tts.speak(message);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }


  Future<String?> listen() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('Speech Status: $val'),
      onError: (val) => print('Speech Error: $val'),
    );

    if (!available) return null;

    String recognizedWords = "";

    Future.delayed(const Duration(seconds: 2)).then((value) {
      _speech.listen(
        pauseFor: const Duration(seconds: 9),
        listenFor: const Duration(seconds: 9),
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            recognizedWords = val.recognizedWords;
          }
        },
      );
    });
    await Future.delayed(const Duration(seconds: 7));
    return recognizedWords.toLowerCase().trim();
  }

  Future<void> stopListening() async {
    if (const RouteSettings().name != '/homePatient') {
      await _speech.stop();
      await _tts.stop();
    }
  }
}
