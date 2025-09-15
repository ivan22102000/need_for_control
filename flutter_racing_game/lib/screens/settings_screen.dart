import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surface, AppColors.background],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            _buildSection(title: 'PLAYER', children: [_buildPlayerNameField()]),

            _buildSection(
              title: 'CONTROLS',
              children: [_buildControlSchemeSelector(), _buildEsp32Settings()],
            ),

            _buildSection(
              title: 'GAME',
              children: [_buildDifficultySelector()],
            ),

            _buildSection(
              title: 'AUDIO',
              children: [
                _buildSoundToggle(),
                _buildMusicToggle(),
                _buildVolumeSliders(),
              ],
            ),

            _buildSection(
              title: 'DISPLAY',
              children: [_buildDisplaySettings()],
            ),

            _buildSection(
              title: 'STATISTICS',
              children: [_buildStatsDisplay(), _buildResetButton()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerNameField() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return TextFormField(
          initialValue: settings.playerName,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Player Name',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onChanged: (value) {
            settings.setPlayerName(value);
          },
        );
      },
    );
  }

  Widget _buildControlSchemeSelector() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control Scheme',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ...ControlScheme.values.map((scheme) {
              return RadioListTile<ControlScheme>(
                title: Text(
                  _getControlSchemeName(scheme),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  _getControlSchemeDescription(scheme),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                value: scheme,
                groupValue: settings.controlScheme,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  if (value != null) {
                    settings.setControlScheme(value);
                  }
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEsp32Settings() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Enable ESP32 Controller',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Connect to external ESP32 racing wheel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              value: settings.esp32Enabled,
              activeColor: AppColors.primary,
              onChanged: (value) {
                settings.setEsp32Enabled(value);
              },
            ),
            if (settings.esp32Enabled) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              TextFormField(
                initialValue: settings.esp32ServerUrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'ESP32 Server URL',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintText: 'ws://192.168.1.100:8080/racing',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (value) {
                  settings.setEsp32ServerUrl(value);
                },
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Row(
                children: [
                  Icon(
                    settings.esp32Connected ? Icons.wifi : Icons.wifi_off,
                    color: settings.esp32Connected
                        ? AppColors.success
                        : AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    settings.esp32Connected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: settings.esp32Connected
                          ? AppColors.success
                          : AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDifficultySelector() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Difficulty',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            DropdownButtonFormField<Difficulty>(
              value: settings.difficulty,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              dropdownColor: AppColors.surface,
              items: Difficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(_getDifficultyName(difficulty)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.setDifficulty(value);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSoundToggle() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SwitchListTile(
          title: const Text(
            'Sound Effects',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          value: settings.soundEnabled,
          activeColor: AppColors.primary,
          onChanged: (value) {
            settings.setSoundEnabled(value);
          },
        );
      },
    );
  }

  Widget _buildMusicToggle() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SwitchListTile(
          title: const Text(
            'Background Music',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          value: settings.musicEnabled,
          activeColor: AppColors.primary,
          onChanged: (value) {
            settings.setMusicEnabled(value);
          },
        );
      },
    );
  }

  Widget _buildVolumeSliders() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          children: [
            _buildSlider(
              label: 'SFX Volume',
              value: settings.sfxVolume,
              onChanged: settings.setSfxVolume,
            ),
            _buildSlider(
              label: 'Music Volume',
              value: settings.musicVolume,
              onChanged: settings.setMusicVolume,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${(value * 100).round()}%',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.textMuted,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDisplaySettings() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Show FPS',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              value: settings.showFPS,
              activeColor: AppColors.primary,
              onChanged: (value) {
                settings.setShowFPS(value);
              },
            ),
            SwitchListTile(
              title: const Text(
                'Show Minimap',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              value: settings.showMinimap,
              activeColor: AppColors.primary,
              onChanged: (value) {
                settings.setShowMinimap(value);
              },
            ),
            SwitchListTile(
              title: const Text(
                'Show Speedometer',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              value: settings.showSpeedometer,
              activeColor: AppColors.primary,
              onChanged: (value) {
                settings.setShowSpeedometer(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsDisplay() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          children: [
            _buildStatRow('Games Played', settings.gamesPlayed.toString()),
            _buildStatRow('Total Distance', settings.totalDistanceFormatted),
            _buildStatRow('Best Lap Time', settings.bestLapTimeFormatted),
            _buildStatRow('Total Wins', settings.totalWins.toString()),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          children: [
            const SizedBox(height: AppSizes.paddingMedium),
            ElevatedButton(
              onPressed: () {
                _showResetDialog(context, settings);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset Statistics'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Reset Statistics',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to reset all statistics? This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                settings.resetStatistics();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Statistics reset successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getControlSchemeName(ControlScheme scheme) {
    switch (scheme) {
      case ControlScheme.touch:
        return 'Touch Controls';
      case ControlScheme.tilt:
        return 'Tilt Controls';
      case ControlScheme.esp32:
        return 'ESP32 Controller';
    }
  }

  String _getControlSchemeDescription(ControlScheme scheme) {
    switch (scheme) {
      case ControlScheme.touch:
        return 'On-screen steering wheel and buttons';
      case ControlScheme.tilt:
        return 'Tilt device to steer';
      case ControlScheme.esp32:
        return 'External ESP32 racing controller';
    }
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.normal:
        return 'Normal';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }
}
