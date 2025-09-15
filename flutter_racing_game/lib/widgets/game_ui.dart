import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class GameUI extends StatelessWidget {
  const GameUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Stack(
          children: [
            // Speedometer (if enabled)
            if (settings.showSpeedometer)
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 20,
                child: _buildSpeedometer(),
              ),

            // Lap info (top center)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 0,
              right: 0,
              child: _buildLapInfo(),
            ),

            // Minimap (if enabled)
            if (settings.showMinimap)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 60,
                child: _buildMinimap(),
              ),

            // FPS counter (if enabled)
            if (settings.showFPS)
              Positioned(bottom: 20, left: 20, child: _buildFPSCounter()),

            // Race progress bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: 20,
              right: 20,
              child: _buildProgressBar(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpeedometer() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: SpeedometerPainter(
              speed: gameProvider.speedKmh,
              maxSpeed: GameConstants.maxSpeed * 3.6, // Convert to km/h
            ),
          ),
        );
      },
    );
  }

  Widget _buildLapInfo() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LAP ${gameProvider.currentLap}/${gameProvider.totalLaps}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    gameProvider.lapTimeFormatted,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (gameProvider.bestLapTime != double.infinity) ...[
                const SizedBox(height: 2),
                Text(
                  'Best: ${gameProvider.bestLapTimeFormatted}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMinimap() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          width: 100,
          height: 80,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: CustomPaint(
            painter: MinimapPainter(
              carX: gameProvider.carX,
              carY: gameProvider.carY,
              carAngle: gameProvider.carAngle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFPSCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: const Text(
        '60 FPS', // Would need actual FPS calculation
        style: TextStyle(
          color: AppColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: gameProvider.raceProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;

  SpeedometerPainter({required this.speed, required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = AppColors.surface.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);

    // Draw speed scale marks
    final markPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      final angle = -math.pi + (i / 10) * math.pi;
      final startRadius = radius - 15;
      final endRadius = radius - 5;

      final startPoint =
          center +
          Offset(math.cos(angle) * startRadius, math.sin(angle) * startRadius);

      final endPoint =
          center +
          Offset(math.cos(angle) * endRadius, math.sin(angle) * endRadius);

      canvas.drawLine(startPoint, endPoint, markPaint);
    }

    // Draw speed needle
    final speedRatio = (speed / maxSpeed).clamp(0.0, 1.0);
    final needleAngle = -math.pi + speedRatio * math.pi;

    final needlePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final needleEnd =
        center +
        Offset(
          math.cos(needleAngle) * (radius - 20),
          math.sin(needleAngle) * (radius - 20),
        );

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, centerDotPaint);

    // Draw speed text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${speed.round()}',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2 - 15),
    );

    // Draw "km/h" label
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'km/h',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );

    labelPainter.layout();
    labelPainter.paint(
      canvas,
      center - Offset(labelPainter.width / 2, labelPainter.height / 2 - 5),
    );
  }

  @override
  bool shouldRepaint(SpeedometerPainter oldDelegate) {
    return oldDelegate.speed != speed || oldDelegate.maxSpeed != maxSpeed;
  }
}

class MinimapPainter extends CustomPainter {
  final double carX;
  final double carY;
  final double carAngle;

  MinimapPainter({
    required this.carX,
    required this.carY,
    required this.carAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw minimap background
    final backgroundPaint = Paint()
      ..color = AppColors.grassColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw minimap track (simplified)
    final trackPaint = Paint()
      ..color = AppColors.trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final trackRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    canvas.drawOval(trackRect, trackPaint);

    // Draw car position on minimap
    // Scale car position to minimap coordinates
    final mapCarX =
        (carX / 800) * size.width; // Assuming game world is 800px wide
    final mapCarY =
        (carY / 600) * size.height; // Assuming game world is 600px tall

    final carPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(mapCarX, mapCarY), 3, carPaint);

    // Draw car direction indicator
    final directionPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final directionEnd =
        Offset(mapCarX, mapCarY) +
        Offset(math.cos(carAngle) * 6, math.sin(carAngle) * 6);

    canvas.drawLine(Offset(mapCarX, mapCarY), directionEnd, directionPaint);
  }

  @override
  bool shouldRepaint(MinimapPainter oldDelegate) {
    return oldDelegate.carX != carX ||
        oldDelegate.carY != carY ||
        oldDelegate.carAngle != carAngle;
  }
}
