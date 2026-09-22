import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MockMapView extends StatefulWidget {
  final int etaMinutes;
  final double distanceKm;
  final String statusText;
  final bool showHeaderBadge;
  final double height;

  const MockMapView({
    super.key,
    this.etaMinutes = 5,
    this.distanceKm = 1.8,
    this.statusText = "Light Traffic Corridor",
    this.showHeaderBadge = true,
    this.height = 320,
  });

  @override
  State<MockMapView> createState() => _MockMapViewState();
}

class _MockMapViewState extends State<MockMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isTrafficLayerOn = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: const Color(0xFFF1F4F8),
      child: Stack(
        children: [
          // Canvas Vector Map
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MapCanvasPainter(
                    pulseValue: _pulseController.value,
                    showTraffic: _isTrafficLayerOn,
                  ),
                );
              },
            ),
          ),

          // Top Floating Telemetry & ETA HUD
          if (widget.showHeaderBadge)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.emergency,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${widget.etaMinutes}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'MIN AWAY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.distanceKm} km • ${widget.statusText}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flash_on, size: 12, color: AppColors.tertiary),
                          SizedBox(width: 2),
                          Text(
                            'PRIORITY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.tertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Map Control Floating Buttons (Recenter / Layers)
          Positioned(
            right: 12,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapActionButton(
                  icon: Icons.my_location,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Map recentered on emergency route"),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMapActionButton(
                  icon: _isTrafficLayerOn ? Icons.layers : Icons.layers_clear,
                  color: _isTrafficLayerOn ? AppColors.primary : AppColors.secondary,
                  onTap: () {
                    setState(() {
                      _isTrafficLayerOn = !_isTrafficLayerOn;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.onSurface,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  final double pulseValue;
  final bool showTraffic;

  _MapCanvasPainter({
    required this.pulseValue,
    required this.showTraffic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. City Blocks Background
    final blockPaint = Paint()..color = const Color(0xFFE9EDF2);
    final parkPaint = Paint()..color = const Color(0xFFE1EFEA);

    // Simulated architectural blocks
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(10, 20, w * 0.35, h * 0.28), const Radius.circular(8)),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, 10, w * 0.5, h * 0.25), const Radius.circular(8)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(15, h * 0.58, w * 0.4, h * 0.35), const Radius.circular(8)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, h * 0.5, w * 0.4, h * 0.4), const Radius.circular(8)),
      blockPaint,
    );

    // 2. Base Road Grid
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD3D9E2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final pathH = Path()
      ..moveTo(0, h * 0.42)
      ..lineTo(w, h * 0.42);
    canvas.drawPath(pathH, roadBorderPaint);
    canvas.drawPath(pathH, roadPaint);

    final pathV = Path()
      ..moveTo(w * 0.48, 0)
      ..lineTo(w * 0.48, h);
    canvas.drawPath(pathV, roadBorderPaint);
    canvas.drawPath(pathV, roadPaint);

    final pathDiag = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.5, h * 0.7, w, h * 0.2);
    canvas.drawPath(pathDiag, roadBorderPaint);
    canvas.drawPath(pathDiag, roadPaint);

    // 3. Emergency Dispatch Route
    final startPt = Offset(w * 0.20, h * 0.32);
    final controlPt1 = Offset(w * 0.35, h * 0.72);
    final controlPt2 = Offset(w * 0.60, h * 0.45);
    final endPt = Offset(w * 0.78, h * 0.72);

    final routePath = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..cubicTo(controlPt1.dx, controlPt1.dy, controlPt2.dx, controlPt2.dy, endPt.dx, endPt.dy);

    final routeGlowPaint = Paint()
      ..color = AppColors.primaryFixed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, routeGlowPaint);

    final routeCorePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, routeCorePaint);

    // 4. Markers
    _drawUserMarker(canvas, endPt);
    _drawAmbulanceMarker(canvas, startPt);
  }

  void _drawUserMarker(Canvas canvas, Offset position) {
    final pulsePaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: (1 - pulseValue) * 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 16 + (14 * pulseValue), pulsePaint);

    canvas.drawCircle(
      position.translate(0, 2),
      9,
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    final corePaint = Paint()..color = AppColors.tertiary;
    canvas.drawCircle(position, 8, corePaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(position, 3.5, innerPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: "You • Sec 62",
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position.translate(0, -22),
        width: textPainter.width + 16,
        height: 22,
      ),
      const Radius.circular(11),
    );

    canvas.drawRRect(
      badgeRect,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = AppColors.borderLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, -29),
    );
  }

  void _drawAmbulanceMarker(Canvas canvas, Offset position) {
    final beaconPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: (1 - pulseValue) * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 14 + (16 * pulseValue), beaconPaint);

    final ambulanceBasePaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(position, 14, ambulanceBasePaint);

    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      position.translate(-5, 0),
      position.translate(5, 0),
      crossPaint,
    );
    canvas.drawLine(
      position.translate(0, -5),
      position.translate(0, 5),
      crossPaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: "Unit #402 (ALS)",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position.translate(0, -22),
        width: textPainter.width + 16,
        height: 20,
      ),
      const Radius.circular(10),
    );

    canvas.drawRRect(
      badgeRect,
      Paint()..color = AppColors.primaryContainer..style = PaintingStyle.fill,
    );
    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, -28),
    );
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.showTraffic != showTraffic;
  }
}
