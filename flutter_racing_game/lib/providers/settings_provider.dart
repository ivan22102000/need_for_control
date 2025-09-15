import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  // Settings values
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _sfxVolume = AudioConstants.defaultSFXVolume;
  double _musicVolume = AudioConstants.defaultMusicVolume;
  Difficulty _difficulty = Difficulty.normal;
  ControlScheme _controlScheme = ControlScheme.touch;
  String _playerName = 'Player';

  // ESP32 connection settings
  bool _esp32Enabled = false;
  String _esp32ServerUrl = 'ws://192.168.1.100:8080/racing';
  bool _esp32Connected = false;

  // Game preferences
  bool _showFPS = false;
  bool _showMinimap = true;
  bool _showSpeedometer = true;
  bool _enableParticles = true;
  double _cameraZoom = 1.0;

  // Statistics
  int _gamesPlayed = 0;
  double _totalDistance = 0.0;
  double _bestLapTime = double.infinity;
  int _totalWins = 0;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;
  Difficulty get difficulty => _difficulty;
  ControlScheme get controlScheme => _controlScheme;
  String get playerName => _playerName;

  bool get esp32Enabled => _esp32Enabled;
  String get esp32ServerUrl => _esp32ServerUrl;
  bool get esp32Connected => _esp32Connected;

  bool get showFPS => _showFPS;
  bool get showMinimap => _showMinimap;
  bool get showSpeedometer => _showSpeedometer;
  bool get enableParticles => _enableParticles;
  double get cameraZoom => _cameraZoom;

  int get gamesPlayed => _gamesPlayed;
  double get totalDistance => _totalDistance;
  double get bestLapTime => _bestLapTime;
  int get totalWins => _totalWins;

  // Initialize settings from storage
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _soundEnabled = prefs.getBool(StorageKeys.soundEnabled) ?? true;
      _musicEnabled = prefs.getBool(StorageKeys.musicEnabled) ?? true;
      _vibrationEnabled = prefs.getBool(StorageKeys.vibrationEnabled) ?? true;
      _sfxVolume =
          prefs.getDouble('sfx_volume') ?? AudioConstants.defaultSFXVolume;
      _musicVolume =
          prefs.getDouble('music_volume') ?? AudioConstants.defaultMusicVolume;

      // Load difficulty
      String difficultyString =
          prefs.getString(StorageKeys.difficulty) ?? 'normal';
      _difficulty = Difficulty.values.firstWhere(
        (d) => d.toString().split('.').last == difficultyString,
        orElse: () => Difficulty.normal,
      );

      // Load control scheme
      String controlString =
          prefs.getString(StorageKeys.controlScheme) ?? 'touch';
      _controlScheme = ControlScheme.values.firstWhere(
        (c) => c.toString().split('.').last == controlString,
        orElse: () => ControlScheme.touch,
      );

      _playerName = prefs.getString(StorageKeys.playerName) ?? 'Player';

      // ESP32 settings
      _esp32Enabled = prefs.getBool('esp32_enabled') ?? false;
      _esp32ServerUrl =
          prefs.getString('esp32_server_url') ??
          'ws://192.168.1.100:8080/racing';

      // Display settings
      _showFPS = prefs.getBool('show_fps') ?? false;
      _showMinimap = prefs.getBool('show_minimap') ?? true;
      _showSpeedometer = prefs.getBool('show_speedometer') ?? true;
      _enableParticles = prefs.getBool('enable_particles') ?? true;
      _cameraZoom = prefs.getDouble('camera_zoom') ?? 1.0;

      // Statistics
      _gamesPlayed = prefs.getInt(StorageKeys.gamesPlayed) ?? 0;
      _totalDistance = prefs.getDouble(StorageKeys.totalDistance) ?? 0.0;
      _bestLapTime =
          prefs.getDouble(StorageKeys.bestLapTime) ?? double.infinity;
      _totalWins = prefs.getInt('total_wins') ?? 0;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Save settings to storage
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(StorageKeys.soundEnabled, _soundEnabled);
      await prefs.setBool(StorageKeys.musicEnabled, _musicEnabled);
      await prefs.setBool(StorageKeys.vibrationEnabled, _vibrationEnabled);
      await prefs.setDouble('sfx_volume', _sfxVolume);
      await prefs.setDouble('music_volume', _musicVolume);

      await prefs.setString(
        StorageKeys.difficulty,
        _difficulty.toString().split('.').last,
      );
      await prefs.setString(
        StorageKeys.controlScheme,
        _controlScheme.toString().split('.').last,
      );
      await prefs.setString(StorageKeys.playerName, _playerName);

      // ESP32 settings
      await prefs.setBool('esp32_enabled', _esp32Enabled);
      await prefs.setString('esp32_server_url', _esp32ServerUrl);

      // Display settings
      await prefs.setBool('show_fps', _showFPS);
      await prefs.setBool('show_minimap', _showMinimap);
      await prefs.setBool('show_speedometer', _showSpeedometer);
      await prefs.setBool('enable_particles', _enableParticles);
      await prefs.setDouble('camera_zoom', _cameraZoom);

      // Statistics
      await prefs.setInt(StorageKeys.gamesPlayed, _gamesPlayed);
      await prefs.setDouble(StorageKeys.totalDistance, _totalDistance);
      await prefs.setDouble(StorageKeys.bestLapTime, _bestLapTime);
      await prefs.setInt('total_wins', _totalWins);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Setting update methods
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
    saveSettings();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
    saveSettings();
  }

  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    notifyListeners();
    saveSettings();
  }

  void setControlScheme(ControlScheme scheme) {
    _controlScheme = scheme;
    notifyListeners();
    saveSettings();
  }

  void setPlayerName(String name) {
    _playerName = name.trim().isEmpty ? 'Player' : name.trim();
    notifyListeners();
    saveSettings();
  }

  void setEsp32Enabled(bool enabled) {
    _esp32Enabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setEsp32ServerUrl(String url) {
    _esp32ServerUrl = url;
    notifyListeners();
    saveSettings();
  }

  void setEsp32Connected(bool connected) {
    _esp32Connected = connected;
    notifyListeners();
  }

  void setShowFPS(bool show) {
    _showFPS = show;
    notifyListeners();
    saveSettings();
  }

  void setShowMinimap(bool show) {
    _showMinimap = show;
    notifyListeners();
    saveSettings();
  }

  void setShowSpeedometer(bool show) {
    _showSpeedometer = show;
    notifyListeners();
    saveSettings();
  }

  void setEnableParticles(bool enable) {
    _enableParticles = enable;
    notifyListeners();
    saveSettings();
  }

  void setCameraZoom(double zoom) {
    _cameraZoom = zoom.clamp(0.5, 3.0);
    notifyListeners();
    saveSettings();
  }

  // Statistics methods
  void incrementGamesPlayed() {
    _gamesPlayed++;
    notifyListeners();
    saveSettings();
  }

  void addDistance(double distance) {
    _totalDistance += distance;
    notifyListeners();
    saveSettings();
  }

  void updateBestLapTime(double lapTime) {
    if (lapTime < _bestLapTime) {
      _bestLapTime = lapTime;
      notifyListeners();
      saveSettings();
    }
  }

  void incrementWins() {
    _totalWins++;
    notifyListeners();
    saveSettings();
  }

  // Reset methods
  void resetStatistics() {
    _gamesPlayed = 0;
    _totalDistance = 0.0;
    _bestLapTime = double.infinity;
    _totalWins = 0;
    notifyListeners();
    saveSettings();
  }

  void resetToDefaults() {
    _soundEnabled = true;
    _musicEnabled = true;
    _vibrationEnabled = true;
    _sfxVolume = AudioConstants.defaultSFXVolume;
    _musicVolume = AudioConstants.defaultMusicVolume;
    _difficulty = Difficulty.normal;
    _controlScheme = ControlScheme.touch;
    _playerName = 'Player';

    _esp32Enabled = false;
    _esp32ServerUrl = 'ws://192.168.1.100:8080/racing';
    _esp32Connected = false;

    _showFPS = false;
    _showMinimap = true;
    _showSpeedometer = true;
    _enableParticles = true;
    _cameraZoom = 1.0;

    notifyListeners();
    saveSettings();
  }

  // Utility methods
  String get difficultyDisplayName {
    switch (_difficulty) {
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

  String get controlSchemeDisplayName {
    switch (_controlScheme) {
      case ControlScheme.touch:
        return 'Touch Controls';
      case ControlScheme.tilt:
        return 'Tilt Controls';
      case ControlScheme.esp32:
        return 'ESP32 Controller';
    }
  }

  String get totalDistanceFormatted {
    if (_totalDistance < 1000) {
      return '${_totalDistance.toStringAsFixed(0)}m';
    } else {
      return '${(_totalDistance / 1000).toStringAsFixed(1)}km';
    }
  }

  String get bestLapTimeFormatted {
    if (_bestLapTime == double.infinity) return '--:--.--';
    int minutes = (_bestLapTime / 60).floor();
    double seconds = _bestLapTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(2).padLeft(5, '0')}';
  }
}
