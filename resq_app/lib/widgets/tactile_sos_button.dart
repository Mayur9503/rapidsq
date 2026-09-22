import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class TactileSosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final double size;
  final Duration holdDuration;

  const TactileSosButton({
    super.key,
    required this.onTriggered,
    this.size = 176.0,
    this.holdDuration = const Duration(seconds: 2),
  });

  @override
  State<TactileSosButton> createState() => _TactileSosButtonState();
}

class _TactileSosButtonState extends State<TactileSosButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _holdProgressController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _holdProgressController = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _holdProgressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onTriggered();
        _resetHold();
      }
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isPressed = true);
    HapticFeedback.mediumImpact();
    _holdProgressController.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    _resetHold();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _resetHold();
  }

  void _resetHold() {
    if (mounted) {
      setState(() => _isPressed = false);
      _holdProgressController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 110,
      height: widget.size + 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Concentric Pulse Waves
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final val = _pulseController.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.size + 90 * val,
                    height: widget.size + 90 * val,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer.withValues(alpha: (1 - val) * 0.15),
                    ),
                  ),
                  Container(
                    width: widget.size + 50 * val,
                    height: widget.size + 50 * val,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer.withValues(alpha: (1 - val) * 0.25),
                    ),
                  ),
                ],
              );
            },
          ),
          // Base outer glow disc
          Container(
            width: widget.size + 24,
            height: widget.size + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryFixed.withValues(alpha: 0.55),
            ),
          ),
          // Interactive Tactile Button Disc
          Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: AnimatedScale(
              scale: _isPressed ? 0.94 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular progress ring
                    AnimatedBuilder(
                      animation: _holdProgressController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: _HoldProgressPainter(
                            progress: _holdProgressController.value,
                            color: Colors.white,
                            strokeWidth: 6.0,
                          ),
                        );
                      },
                    ),
                    // Centered SOS Typography & Sub-text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'SOS',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: AppColors.onPrimary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _isPressed ? 'HOLDING...' : 'HOLD 2S',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.primaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _HoldProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2 - 4;

    // Track Background
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HoldProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
