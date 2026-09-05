import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  FlutterTts? _flutterTts;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      _flutterTts = FlutterTts();
      await _flutterTts?.setSpeechRate(0.48);
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(1.0);

      _flutterTts?.setStartHandler(() {
        _isSpeaking = true;
      });
      _flutterTts?.setCompletionHandler(() {
        _isSpeaking = false;
      });
      _flutterTts?.setErrorHandler((msg) {
        _isSpeaking = false;
      });
    } catch (e) {
      debugPrint('[AudioService] Init error: $e');
    }
  }

  Future<void> speak(String text, {String lang = 'hi'}) async {
    try {
      if (_flutterTts == null) {
        await init();
      }

      final ttsLang = lang == 'mr'
          ? 'mr-IN'
          : lang == 'hi'
              ? 'hi-IN'
              : 'en-IN';

      await _flutterTts?.setLanguage(ttsLang);
      await _flutterTts?.stop();
      await _flutterTts?.speak(text);
    } catch (e) {
      debugPrint('[AudioService] Speech fallback: $text ($e)');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts?.stop();
      _isSpeaking = false;
    } catch (_) {}
  }
}
