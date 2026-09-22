import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/emergency_enums.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final ValueChanged<String?>? onVoiceRecorded;
  final VoidCallback? onSend;
  final bool compact;

  const VoiceRecorderWidget({
    super.key,
    this.onVoiceRecorded,
    this.onSend,
    this.compact = false,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  VoiceRecordState _state = VoiceRecordState.idle;
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _waveformController;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  void _startRecording() {
    setState(() {
      _state = VoiceRecordState.recording;
      _seconds = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds < 15) {
        setState(() {
          _seconds++;
        });
      } else {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _state = VoiceRecordState.recorded;
    });
    widget.onVoiceRecorded?.call('${_seconds}s voice note');
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _state = VoiceRecordState.idle;
      _seconds = 0;
    });
    widget.onVoiceRecorded?.call(null);
  }

  void _togglePlayback() {
    setState(() {
      if (_state == VoiceRecordState.playing) {
        _state = VoiceRecordState.recorded;
      } else {
        _state = VoiceRecordState.playing;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.compact ? 12 : 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _state == VoiceRecordState.recording
              ? AppColors.primary
              : AppColors.borderLight,
          width: _state == VoiceRecordState.recording ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Status & Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _state == VoiceRecordState.recording
                            ? AppColors.primary
                            : _state == VoiceRecordState.recorded
                                ? AppColors.tertiary
                                : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _state == VoiceRecordState.idle
                            ? '15-Sec Emergency Voice Note'
                            : _state == VoiceRecordState.recording
                                ? 'RECORDING DISPATCH INTEL'
                                : _state == VoiceRecordState.playing
                                    ? 'PLAYING BACK'
                                    : 'RECORDING READY (15s MAX)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: _state == VoiceRecordState.recording
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '00:${_seconds.toString().padLeft(2, '0')} / 00:15',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Waveform visualization
          Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedBuilder(
              animation: _waveformController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(24, (index) {
                    double barHeight = 8.0;
                    if (_state == VoiceRecordState.recording) {
                      barHeight = 10.0 + _random.nextDouble() * 32.0;
                    } else if (_state == VoiceRecordState.playing) {
                      barHeight = 12.0 + math.sin(index + _waveformController.value * 6) * 16.0;
                    } else if (_state == VoiceRecordState.recorded) {
                      barHeight = (index % 5 + 2) * 6.0;
                    }
                    return Container(
                      width: 4,
                      height: barHeight.clamp(6.0, 42.0),
                      decoration: BoxDecoration(
                        color: _state == VoiceRecordState.recording
                            ? AppColors.primary
                            : _state == VoiceRecordState.playing
                                ? AppColors.tertiary
                                : AppColors.secondary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Action Controls depending on state
          if (_state == VoiceRecordState.idle)
            ElevatedButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.mic, color: Colors.white, size: 22),
              label: const Text('HOLD OR TAP TO RECORD (15s)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
            )
          else if (_state == VoiceRecordState.recording)
            ElevatedButton.icon(
              onPressed: _stopRecording,
              icon: const Icon(Icons.stop, color: Colors.white, size: 22),
              label: const Text('STOP RECORDING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inverseSurface,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Re-record'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _togglePlayback,
                    icon: Icon(
                      _state == VoiceRecordState.playing ? Icons.pause : Icons.play_arrow,
                      size: 20,
                      color: AppColors.tertiary,
                    ),
                    label: Text(_state == VoiceRecordState.playing ? 'Pause' : 'Listen'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                if (widget.onSend != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onSend,
                      icon: const Icon(Icons.send, size: 18, color: Colors.white),
                      label: const Text('Send'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
