import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/game_canvas.dart';
import '../widgets/touch_controls.dart';
import '../widgets/game_ui.dart';
import '../widgets/pause_menu.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _gameLoopController;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize game loop
    _gameLoopController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Start game loop
    _gameLoopController.addListener(_gameLoop);
    _gameLoopController.repeat();

    // Start the game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startGame();
    });
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    super.dispose();
  }

  void _gameLoop() {
    final now = DateTime.now();
    final deltaTime = now.difference(_lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = now;

    // Update game physics
    context.read<GameProvider>().updatePhysics(deltaTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Stack(
            children: [
              // Main game canvas
              const GameCanvas(),

              // Game UI overlay
              const GameUI(),

              // Touch controls (only show when using touch controls)
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  if (settings.controlScheme == ControlScheme.touch) {
                    return const TouchControls();
                  }
                  return const SizedBox();
                },
              ),

              // Pause menu overlay
              if (gameProvider.gameState == GameState.paused) const PauseMenu(),

              // Game over overlay
              if (gameProvider.gameState == GameState.gameOver)
                _buildGameOverOverlay(),

              // Back button (top-left)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: _buildBackButton(),
              ),

              // Pause button (top-right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: _buildPauseButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: IconButton(
        onPressed: () {
          _showExitDialog();
        },
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildPauseButton() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.gameState != GameState.playing) {
          return const SizedBox();
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: () {
              gameProvider.pauseGame();
            },
            icon: const Icon(Icons.pause, color: AppColors.textPrimary),
          ),
        );
      },
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: AppColors.background.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSizes.paddingLarge),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Game Over Title
                  Text(
                    'RACE FINISHED!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingLarge),

                  // Race statistics
                  _buildRaceStats(gameProvider),

                  const SizedBox(height: AppSizes.paddingLarge),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          gameProvider.resetGame();
                          gameProvider.startGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('RACE AGAIN'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          gameProvider.resetGame();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: const Text('MAIN MENU'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRaceStats(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          _buildStatRow('Total Laps', '${gameProvider.currentLap - 1}'),
          _buildStatRow('Current Lap Time', gameProvider.lapTimeFormatted),
          _buildStatRow('Best Lap Time', gameProvider.bestLapTimeFormatted),
          _buildStatRow(
            'Final Speed',
            '${gameProvider.speedKmh.toStringAsFixed(0)} km/h',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Exit Race',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to exit the race? Your progress will be lost.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Continue Racing',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.read<GameProvider>().resetGame();
                Navigator.of(context).pop(); // Go back to main menu
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
