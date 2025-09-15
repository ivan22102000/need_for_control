import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class TouchControls extends StatefulWidget {
  const TouchControls({super.key});

  @override
  State<TouchControls> createState() => _TouchControlsState();
}

class _TouchControlsState extends State<TouchControls> {
  // Steering wheel state
  Offset _steeringCenter = Offset.zero;
  Offset _steeringPosition = Offset.zero;
  bool _steeringActive = false;

  // Acceleration/brake state
  double _accelerationValue = 0.0;
  bool _handbrakePressed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Steering wheel (left side)
        Positioned(left: 30, bottom: 30, child: _buildSteeringWheel()),

        // Acceleration/Brake controls (right side)
        Positioned(right: 30, bottom: 30, child: _buildAccelerationControls()),

        // Handbrake button (center-right)
        Positioned(right: 30, bottom: 200, child: _buildHandbrakeButton()),
      ],
    );
  }

  Widget _buildSteeringWheel() {
    return GestureDetector(
      onPanStart: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final globalPosition = renderBox.globalToLocal(details.globalPosition);
        _steeringCenter = globalPosition;
        _steeringPosition = globalPosition;
        _steeringActive = true;
        setState(() {});
      },
      onPanUpdate: (details) {
        if (!_steeringActive) return;

        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final globalPosition = renderBox.globalToLocal(details.globalPosition);

        // Calculate offset from center
        final offset = globalPosition - _steeringCenter;
        final distance = offset.distance;
        final maxDistance = AppSizes.steeringWheelSize / 2;

        // Limit steering to wheel bounds
        if (distance <= maxDistance) {
          _steeringPosition = globalPosition;
        } else {
          final direction = offset / distance;
          _steeringPosition = _steeringCenter + direction * maxDistance;
        }

        // Calculate steering input (-1 to 1)
        final steeringInput = offset.dx / maxDistance;
        context.read<GameProvider>().setSteeringInput(
          steeringInput.clamp(-1.0, 1.0),
        );

        setState(() {});
      },
      onPanEnd: (details) {
        _steeringActive = false;
        _steeringPosition = _steeringCenter;
        context.read<GameProvider>().setSteeringInput(0.0);
        setState(() {});
      },
      child: SizedBox(
        width: AppSizes.steeringWheelSize,
        height: AppSizes.steeringWheelSize,
        child: CustomPaint(
          painter: SteeringWheelPainter(
            center: _steeringCenter,
            knobPosition: _steeringPosition,
            isActive: _steeringActive,
          ),
        ),
      ),
    );
  }

  Widget _buildAccelerationControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Acceleration slider
        GestureDetector(
          onPanStart: (details) {
            _updateAcceleration(details.localPosition);
          },
          onPanUpdate: (details) {
            _updateAcceleration(details.localPosition);
          },
          onPanEnd: (details) {
            _accelerationValue = 0.0;
            context.read<GameProvider>().setAccelerationInput(0.0);
            setState(() {});
          },
          child: Container(
            width: 60,
            height: AppSizes.sliderHeight,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: CustomPaint(
              painter: AccelerationSliderPainter(value: _accelerationValue),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Control labels
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'GAS',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'BRAKE',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHandbrakeButton() {
    return GestureDetector(
      onTapDown: (details) {
        _handbrakePressed = true;
        context.read<GameProvider>().setHandbrake(true);
        setState(() {});
      },
      onTapUp: (details) {
        _handbrakePressed = false;
        context.read<GameProvider>().setHandbrake(false);
        setState(() {});
      },
      onTapCancel: () {
        _handbrakePressed = false;
        context.read<GameProvider>().setHandbrake(false);
        setState(() {});
      },
      child: Container(
        width: AppSizes.buttonSize,
        height: AppSizes.buttonSize,
        decoration: BoxDecoration(
          color: _handbrakePressed
              ? AppColors.error
              : AppColors.surface.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.error, width: 2),
          boxShadow: _handbrakePressed
              ? [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.sports_motorsports,
          color: _handbrakePressed ? Colors.white : AppColors.error,
          size: 30,
        ),
      ),
    );
  }

  void _updateAcceleration(Offset position) {
    final centerY = AppSizes.sliderHeight / 2;
    final offsetY = position.dy - centerY;
    final normalizedY = -offsetY / (AppSizes.sliderHeight / 2);

    _accelerationValue = normalizedY.clamp(-1.0, 1.0);
    context.read<GameProvider>().setAccelerationInput(_accelerationValue);
    setState(() {});
  }
}

class SteeringWheelPainter extends CustomPainter {
  final Offset center;
  final Offset knobPosition;
  final bool isActive;

  SteeringWheelPainter({
    required this.center,
    required this.knobPosition,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerPoint = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer ring
    final outerPaint = Paint()
      ..color = isActive ? AppColors.primary : AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(centerPoint, radius - 2, outerPaint);

    // Draw inner background
    final backgroundPaint = Paint()
      ..color = AppColors.surface.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(centerPoint, radius - 4, backgroundPaint);

    // Draw steering wheel spokes
    final spokePaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final spokeStart =
          centerPoint +
          Offset(
            math.cos(angle) * (radius * 0.3),
            math.sin(angle) * (radius * 0.3),
          );
      final spokeEnd =
          centerPoint +
          Offset(
            math.cos(angle) * (radius * 0.8),
            math.sin(angle) * (radius * 0.8),
          );

      canvas.drawLine(spokeStart, spokeEnd, spokePaint);
    }

    // Draw center knob
    final knobRadius = 15.0;
    final knobPaint = Paint()
      ..color = isActive ? AppColors.secondary : AppColors.textSecondary
      ..style = PaintingStyle.fill;

    // Calculate knob position relative to steering input
    final steeringOffset = knobPosition - center;
    final knobCenter = centerPoint + steeringOffset;

    canvas.drawCircle(knobCenter, knobRadius, knobPaint);

    // Draw knob border
    final knobBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(knobCenter, knobRadius, knobBorderPaint);
  }

  @override
  bool shouldRepaint(SteeringWheelPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.knobPosition != knobPosition ||
        oldDelegate.isActive != isActive;
  }
}

class AccelerationSliderPainter extends CustomPainter {
  final double value; // -1 to 1

  AccelerationSliderPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final width = size.width;

    // Draw center line
    final centerLinePaint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(width * 0.2, centerY),
      Offset(width * 0.8, centerY),
      centerLinePaint,
    );

    // Draw acceleration/brake zones
    final zonePaint = Paint()..style = PaintingStyle.fill;

    // Green zone (top half - acceleration)
    zonePaint.color = AppColors.success.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, centerY), zonePaint);

    // Red zone (bottom half - brake)
    zonePaint.color = AppColors.error.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, centerY, width, centerY), zonePaint);

    // Draw current position indicator
    final indicatorY = centerY - (value * centerY);
    final indicatorPaint = Paint()
      ..color = value > 0
          ? AppColors.success
          : value < 0
          ? AppColors.error
          : AppColors.textSecondary
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(width * 0.1, indicatorY - 15, width * 0.8, 30),
      indicatorPaint,
    );

    // Draw indicator border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(width * 0.1, indicatorY - 15, width * 0.8, 30),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(AccelerationSliderPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
