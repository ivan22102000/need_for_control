import 'package:flutter/material.dart';

class AppColors {
  // Racing theme colors
  static const Color primary = Color(0xFFE53E3E); // Racing red
  static const Color secondary = Color(0xFF38B2AC); // Teal
  static const Color accent = Color(0xFFFFB800); // Racing yellow

  // Background colors
  static const Color background = Color(0xFF0A0A0A); // Almost black
  static const Color surface = Color(0xFF1A1A1A); // Dark gray
  static const Color cardBackground = Color(0xFF2D2D2D); // Lighter gray

  // Game specific colors
  static const Color trackColor = Color(0xFF404040); // Track gray
  static const Color grassColor = Color(0xFF2D5016); // Dark green
  static const Color finishLine = Color(0xFFFFFFFF); // White

  // UI colors
  static const Color success = Color(0xFF48BB78); // Green
  static const Color warning = Color(0xFFED8936); // Orange
  static const Color error = Color(0xFFE53E3E); // Red
  static const Color info = Color(0xFF4299E1); // Blue

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB3B3B3); // Light gray
  static const Color textMuted = Color(0xFF666666); // Gray
}

class AppSizes {
  // Screen dimensions
  static const double screenRatio = 16 / 9; // Landscape ratio

  // Car dimensions
  static const double carWidth = 30.0;
  static const double carHeight = 15.0;

  // Track dimensions
  static const double trackWidth = 80.0;
  static const double finishLineWidth = 5.0;

  // UI dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Control dimensions
  static const double steeringWheelSize = 120.0;
  static const double buttonSize = 60.0;
  static const double sliderHeight = 200.0;
}

class GameConstants {
  // Physics
  static const double maxSpeed = 200.0; // pixels per second
  static const double acceleration = 100.0; // pixels per second²
  static const double deceleration = 150.0; // pixels per second²
  static const double friction = 50.0; // pixels per second²
  static const double maxSteeringAngle = 2.0; // radians per second
  static const double steeringSpeed = 3.0; // steering response

  // Game settings
  static const int targetFPS = 60;
  static const double worldScale = 1.0;
  static const int maxLaps = 3;

  // Car specifications
  static const double carMass = 1000.0; // kg
  static const double wheelBase = 2.5; // meters
  static const double trackLength = 2000.0; // pixels

  // Track layout
  static const List<TrackPoint> trackPoints = [
    TrackPoint(100, 300), // Start/Finish
    TrackPoint(200, 250), // Turn 1
    TrackPoint(300, 200), // Turn 2
    TrackPoint(500, 150), // Straight
    TrackPoint(700, 200), // Turn 3
    TrackPoint(800, 300), // Turn 4
    TrackPoint(750, 450), // Turn 5
    TrackPoint(600, 500), // Turn 6
    TrackPoint(400, 480), // Turn 7
    TrackPoint(200, 450), // Turn 8
    TrackPoint(100, 350), // Back to start
  ];
}

class TrackPoint {
  final double x;
  final double y;

  const TrackPoint(this.x, this.y);
}

class InputConstants {
  // Touch controls
  static const double deadZone = 0.1; // Minimum input threshold
  static const double sensitivity = 1.0; // Input sensitivity
  static const double steeringDeadZone = 0.05; // Steering dead zone

  // Button press thresholds
  static const Duration longPressThreshold = Duration(milliseconds: 500);
  static const Duration doubleTapThreshold = Duration(milliseconds: 300);
}

class AudioConstants {
  // Sound effects
  static const String engineSound = 'sounds/engine.mp3';
  static const String brakeSound = 'sounds/brake.mp3';
  static const String crashSound = 'sounds/crash.mp3';
  static const String finishSound = 'sounds/finish.mp3';
  static const String backgroundMusic = 'sounds/racing_music.mp3';

  // Volume levels
  static const double defaultSFXVolume = 0.7;
  static const double defaultMusicVolume = 0.5;
}

class AnimationConstants {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve fastCurve = Curves.easeOut;
}

class StorageKeys {
  // SharedPreferences keys
  static const String highScore = 'high_score';
  static const String bestLapTime = 'best_lap_time';
  static const String totalDistance = 'total_distance';
  static const String gamesPlayed = 'games_played';
  static const String soundEnabled = 'sound_enabled';
  static const String musicEnabled = 'music_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  static const String difficulty = 'difficulty';
  static const String controlScheme = 'control_scheme';
  static const String playerName = 'player_name';
}

enum GameState { menu, playing, paused, gameOver, loading, settings }

enum ControlScheme {
  touch, // Touch controls on screen
  tilt, // Device tilt controls
  esp32, // ESP32 external controller
}

enum Difficulty { easy, normal, hard, expert }

class DifficultySettings {
  static Map<Difficulty, Map<String, double>> settings = {
    Difficulty.easy: {
      'aiSpeed': 0.7,
      'aiAggression': 0.3,
      'friction': 0.8,
      'damage': 0.5,
    },
    Difficulty.normal: {
      'aiSpeed': 1.0,
      'aiAggression': 0.6,
      'friction': 1.0,
      'damage': 1.0,
    },
    Difficulty.hard: {
      'aiSpeed': 1.3,
      'aiAggression': 0.8,
      'friction': 1.2,
      'damage': 1.5,
    },
    Difficulty.expert: {
      'aiSpeed': 1.6,
      'aiAggression': 1.0,
      'friction': 1.5,
      'damage': 2.0,
    },
  };
}
