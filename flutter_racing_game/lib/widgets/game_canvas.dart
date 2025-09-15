import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class GameCanvas extends StatefulWidget {
  const GameCanvas({super.key});

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.grassColor,
          child: CustomPaint(
            painter: GamePainter(
              carX: gameProvider.carX,
              carY: gameProvider.carY,
              carAngle: gameProvider.carAngle,
              gameState: gameProvider.gameState,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class GamePainter extends CustomPainter {
  final double carX;
  final double carY;
  final double carAngle;
  final GameState gameState;

  GamePainter({
    required this.carX,
    required this.carY,
    required this.carAngle,
    required this.gameState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grass background (already set as container color)

    // Draw track
    _drawTrack(canvas, size);

    // Draw start/finish line
    _drawFinishLine(canvas, size);

    // Draw car
    _drawCar(canvas, size);

    // Draw track boundaries
    _drawTrackBoundaries(canvas, size);
  }

  void _drawTrack(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = AppColors.trackColor
      ..style = PaintingStyle.fill;

    // Create a simple oval track
    final trackPath = Path();

    // Outer track boundary
    final outerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    // Inner track boundary
    final innerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.5,
      height: size.height * 0.3,
    );

    trackPath.addOval(outerRect);
    trackPath.addOval(innerRect);
    trackPath.fillType = PathFillType.evenOdd;

    canvas.drawPath(trackPath, trackPaint);

    // Draw track center line
    _drawTrackCenterLine(canvas, size);
  }

  void _drawTrackCenterLine(Canvas canvas, Size size) {
    final centerLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Calculate center line path
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.65,
      height: size.height * 0.45,
    );

    final centerPath = Path()..addOval(centerRect);
    canvas.drawPath(centerPath, centerLinePaint);
  }

  void _drawFinishLine(Canvas canvas, Size size) {
    final finishLinePaint = Paint()
      ..color = AppColors.finishLine
      ..strokeWidth = AppSizes.finishLineWidth
      ..style = PaintingStyle.stroke;

    // Draw finish line at the bottom of the track
    final startPoint = Offset(size.width * 0.1, size.height * 0.7);
    final endPoint = Offset(size.width * 0.35, size.height * 0.7);

    canvas.drawLine(startPoint, endPoint, finishLinePaint);

    // Draw checkered pattern
    _drawCheckeredPattern(canvas, startPoint, endPoint);
  }

  void _drawCheckeredPattern(Canvas canvas, Offset start, Offset end) {
    final checkSize = 8.0;
    final blackPaint = Paint()..color = Colors.black;
    final whitePaint = Paint()..color = Colors.white;

    final lineLength = (end - start).distance;
    final numChecks = (lineLength / checkSize).floor();

    for (int i = 0; i < numChecks; i++) {
      final t = i / numChecks;
      final nextT = (i + 1) / numChecks;

      final checkStart = Offset.lerp(start, end, t)!;
      final checkEnd = Offset.lerp(start, end, nextT)!;

      final paint = i.isEven ? blackPaint : whitePaint;

      canvas.drawLine(
        checkStart - Offset(0, AppSizes.finishLineWidth / 2),
        checkEnd - Offset(0, AppSizes.finishLineWidth / 2),
        paint..strokeWidth = AppSizes.finishLineWidth,
      );
    }
  }

  void _drawCar(Canvas canvas, Size size) {
    canvas.save();

    // Translate to car position
    canvas.translate(carX, carY);

    // Rotate based on car angle
    canvas.rotate(carAngle);

    // Draw car body
    final carBodyPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final carRect = Rect.fromCenter(
      center: Offset.zero,
      width: AppSizes.carWidth,
      height: AppSizes.carHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(carRect, const Radius.circular(3)),
      carBodyPaint,
    );

    // Draw car outline
    final carOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(carRect, const Radius.circular(3)),
      carOutlinePaint,
    );

    // Draw car windows
    final windowPaint = Paint()
      ..color = AppColors.background.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final windowRect = Rect.fromCenter(
      center: Offset.zero,
      width: AppSizes.carWidth * 0.6,
      height: AppSizes.carHeight * 0.5,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(2)),
      windowPaint,
    );

    // Draw car direction indicator (front bumper)
    final frontBumperPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        -AppSizes.carWidth / 2,
        -AppSizes.carHeight / 2 - 3,
        AppSizes.carWidth,
        3,
      ),
      frontBumperPaint,
    );

    canvas.restore();
  }

  void _drawTrackBoundaries(Canvas canvas, Size size) {
    final boundaryPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Outer boundary
    final outerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    canvas.drawOval(outerRect, boundaryPaint);

    // Inner boundary
    final innerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.5,
      height: size.height * 0.3,
    );

    canvas.drawOval(innerRect, boundaryPaint);
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return oldDelegate.carX != carX ||
        oldDelegate.carY != carY ||
        oldDelegate.carAngle != carAngle ||
        oldDelegate.gameState != gameState;
  }
}

// Extension for creating simple dashed path effect
extension PathExtension on Path {
  Path createDashedPath(double dashLength, double gapLength) {
    final dashedPath = Path();
    final pathMetrics = computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < pathMetric.length) {
        final segmentLength = draw ? dashLength : gapLength;
        final end = math.min(distance + segmentLength, pathMetric.length);

        if (draw) {
          final segment = pathMetric.extractPath(distance, end);
          dashedPath.addPath(segment, Offset.zero);
        }

        distance = end;
        draw = !draw;
      }
    }

    return dashedPath;
  }
}
