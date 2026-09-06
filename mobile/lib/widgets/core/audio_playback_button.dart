import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../services/localization_service.dart';

class AudioPlaybackButton extends StatefulWidget {
  final String textToSpeak;
  
  const AudioPlaybackButton({Key? key, required this.textToSpeak}) : super(key: key);

  @override
  State<AudioPlaybackButton> createState() => _AudioPlaybackButtonState();
}

class _AudioPlaybackButtonState extends State<AudioPlaybackButton> {
  bool _isPlaying = false;

  void _speak() async {
    setState(() => _isPlaying = true);
    final loc = LocalizationService();
    await AudioService().speak(widget.textToSpeak, lang: loc.currentLanguage);
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Play audio',
      button: true,
      child: InkWell(
        onTap: _isPlaying ? null : _speak,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isPlaying ? const Color(0xFFE0A526).withOpacity(0.5) : const Color(0xFFE0A526),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                color: const Color(0xFF0F172A),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'सुनें',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
