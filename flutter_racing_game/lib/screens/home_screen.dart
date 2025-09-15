import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surface,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title
              _buildHeader(),

              // Main menu content
              Expanded(child: _buildMainMenu()),

              // Footer with version info
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Game title
          Text(
            'NEED FOR CONTROL',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5),

          const SizedBox(height: AppSizes.paddingSmall),

          // Subtitle
          Text(
            'Racing Game',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.secondary,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildMainMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Start Game Button
          _buildMenuButton(
            icon: Icons.play_arrow,
            label: 'START RACE',
            color: AppColors.primary,
            onPressed: () => Navigator.pushNamed(context, '/game'),
          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3),

          const SizedBox(height: AppSizes.paddingMedium),

          // Settings Button
          _buildMenuButton(
            icon: Icons.settings,
            label: 'SETTINGS',
            color: AppColors.secondary,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.3),

          const SizedBox(height: AppSizes.paddingMedium),

          // Stats display
          _buildStatsCard(),

          const SizedBox(height: AppSizes.paddingMedium),

          // ESP32 Status
          _buildEsp32Status(),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          elevation: 8,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'PLAYER STATS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.secondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Games', settings.gamesPlayed.toString()),
                  _buildStatItem('Best Lap', settings.bestLapTimeFormatted),
                  _buildStatItem('Distance', settings.totalDistanceFormatted),
                  _buildStatItem('Wins', settings.totalWins.toString()),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.8, 0.8));
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEsp32Status() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        if (!settings.esp32Enabled) return const SizedBox();

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: settings.esp32Connected
                ? AppColors.success.withOpacity(0.2)
                : AppColors.warning.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: settings.esp32Connected
                  ? AppColors.success
                  : AppColors.warning,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                settings.esp32Connected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: settings.esp32Connected
                    ? AppColors.success
                    : AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                settings.esp32Connected
                    ? 'ESP32 Connected'
                    : 'ESP32 Disconnected',
                style: TextStyle(
                  fontSize: 12,
                  color: settings.esp32Connected
                      ? AppColors.success
                      : AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1200.ms);
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          Text(
            'v1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Touch controls ready • ESP32 support available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1400.ms);
  }
}
