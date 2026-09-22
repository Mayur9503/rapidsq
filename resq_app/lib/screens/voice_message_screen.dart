import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/voice_recorder_widget.dart';

class VoiceMessageScreen extends StatefulWidget {
  const VoiceMessageScreen({super.key});

  @override
  State<VoiceMessageScreen> createState() => _VoiceMessageScreenState();
}

class _VoiceMessageScreenState extends State<VoiceMessageScreen> {
  String? _recordedDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Emergency Voice Note', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.mic, color: AppColors.onSecondaryContainer, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Speak clearly into your phone. Describe victim count, visible bleeding, or exact landmarks.',
                        style: TextStyle(fontSize: 13, color: AppColors.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Embedded Voice Recorder
              VoiceRecorderWidget(
                onVoiceRecorded: (dur) {
                  setState(() => _recordedDuration = dur);
                },
                onSend: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Voice note ($_recordedDuration) attached to dispatch')),
                  );
                  Navigator.of(context).pop(_recordedDuration);
                },
              ),

              const Spacer(),

              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('BACK TO DISPATCH FORM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
