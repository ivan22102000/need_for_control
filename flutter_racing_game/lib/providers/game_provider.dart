import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class GameProvider extends ChangeNotifier {
  // Game state
  GameState _gameState = GameState.menu;
  bool _isPaused = false;

  // Player stats
  double _currentSpeed = 0.0;
  double _currentLapTime = 0.0;
  double _bestLapTime = double.infinity;
  int _currentLap = 1;
  final int _totalLaps = GameConstants.maxLaps;
  double _raceProgress = 0.0; // 0.0 to 1.0

  // Car physics
  double _carX = 100.0;
  double _carY = 300.0;
  double _carAngle = 0.0;
  double _velocity = 0.0;
  double _steeringAngle = 0.0;

  // Controls
  double _accelerationInput = 0.0; // -1.0 to 1.0 (negative is brake)
  double _steeringInput = 0.0; // -1.0 to 1.0 (left to right)
  bool _handbrakePressed = false;

  // Game timing
  DateTime? _raceStartTime;
  DateTime? _lapStartTime;

  // Getters
  GameState get gameState => _gameState;
  bool get isPaused => _isPaused;
  double get currentSpeed => _currentSpeed;
  double get currentLapTime => _currentLapTime;
  double get bestLapTime => _bestLapTime;
  int get currentLap => _currentLap;
  int get totalLaps => _totalLaps;
  double get raceProgress => _raceProgress;

  double get carX => _carX;
  double get carY => _carY;
  double get carAngle => _carAngle;
  double get velocity => _velocity;
  double get steeringAngle => _steeringAngle;

  double get accelerationInput => _accelerationInput;
  double get steeringInput => _steeringInput;
  bool get handbrakePressed => _handbrakePressed;

  // Game control methods
  void startGame() {
    _gameState = GameState.playing;
    _raceStartTime = DateTime.now();
    _lapStartTime = DateTime.now();
    _currentLap = 1;
    _currentLapTime = 0.0;
    _raceProgress = 0.0;
    resetCarPosition();
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState == GameState.playing) {
      _isPaused = true;
      _gameState = GameState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState == GameState.paused) {
      _isPaused = false;
      _gameState = GameState.playing;
      notifyListeners();
    }
  }

  void endGame() {
    _gameState = GameState.gameOver;
    _isPaused = false;
    notifyListeners();
  }

  void resetGame() {
    _gameState = GameState.menu;
    _isPaused = false;
    _currentSpeed = 0.0;
    _currentLapTime = 0.0;
    _currentLap = 1;
    _raceProgress = 0.0;
    _velocity = 0.0;
    _steeringAngle = 0.0;
    _accelerationInput = 0.0;
    _steeringInput = 0.0;
    _handbrakePressed = false;
    resetCarPosition();
    notifyListeners();
  }

  void resetCarPosition() {
    _carX = 100.0;
    _carY = 300.0;
    _carAngle = 0.0;
    _velocity = 0.0;
    notifyListeners();
  }

  // Input methods
  void setAccelerationInput(double input) {
    _accelerationInput = input.clamp(-1.0, 1.0);
    notifyListeners();
  }

  void setSteeringInput(double input) {
    _steeringInput = input.clamp(-1.0, 1.0);
    notifyListeners();
  }

  void setHandbrake(bool pressed) {
    _handbrakePressed = pressed;
    notifyListeners();
  }

  // Physics update method
  void updatePhysics(double deltaTime) {
    if (_gameState != GameState.playing) return;

    // Update steering angle
    _steeringAngle += _steeringInput * GameConstants.steeringSpeed * deltaTime;
    _steeringAngle = _steeringAngle.clamp(
      -GameConstants.maxSteeringAngle,
      GameConstants.maxSteeringAngle,
    );

    // Apply steering decay when no input
    if (_steeringInput.abs() < InputConstants.deadZone) {
      _steeringAngle *= 0.9; // Gradual return to center
    }

    // Calculate acceleration/deceleration
    double acceleration = 0.0;

    if (_accelerationInput > InputConstants.deadZone) {
      // Accelerating
      acceleration = _accelerationInput * GameConstants.acceleration;
    } else if (_accelerationInput < -InputConstants.deadZone) {
      // Braking
      acceleration = _accelerationInput * GameConstants.deceleration;
    } else {
      // Coasting - apply friction
      if (_velocity > 0) {
        acceleration = -GameConstants.friction;
      } else if (_velocity < 0) {
        acceleration = GameConstants.friction;
      }
    }

    // Apply handbrake
    if (_handbrakePressed) {
      acceleration -=
          GameConstants.deceleration * 0.5 * (_velocity > 0 ? 1 : -1);
    }

    // Update velocity
    _velocity += acceleration * deltaTime;
    _velocity = _velocity.clamp(
      -GameConstants.maxSpeed * 0.5,
      GameConstants.maxSpeed,
    );

    // Update car angle based on velocity and steering
    if (_velocity.abs() > 1.0) {
      _carAngle +=
          _steeringAngle * (_velocity / GameConstants.maxSpeed) * deltaTime;
    }

    // Update car position
    _carX += _velocity * cos(_carAngle) * deltaTime;
    _carY += _velocity * sin(_carAngle) * deltaTime;

    // Update current speed (absolute value for display)
    _currentSpeed = _velocity.abs();

    // Update lap time
    if (_lapStartTime != null) {
      _currentLapTime =
          DateTime.now().difference(_lapStartTime!).inMilliseconds / 1000.0;
    }

    // Check for lap completion (simplified)
    _updateRaceProgress();

    notifyListeners();
  }

  void _updateRaceProgress() {
    // Simple progress calculation based on distance from start
    double distanceFromStart = sqrt(
      pow(_carX - 100.0, 2) + pow(_carY - 300.0, 2),
    );

    // This is a simplified progress calculation
    // In a real game, you'd use checkpoints along the track
    if (distanceFromStart < 50.0 && _raceProgress > 0.8) {
      // Completed a lap
      completeLap();
    }

    // Update progress based on car position (simplified)
    _raceProgress = (_carX / GameConstants.trackLength).clamp(0.0, 1.0);
  }

  void completeLap() {
    if (_currentLapTime < _bestLapTime) {
      _bestLapTime = _currentLapTime;
    }

    _currentLap++;
    _lapStartTime = DateTime.now();
    _raceProgress = 0.0;

    if (_currentLap > _totalLaps) {
      endGame();
    }

    notifyListeners();
  }

  // Collision detection
  bool checkCollision(double x, double y) {
    // Simple bounds checking
    // In a real game, you'd check against track boundaries
    return x < 0 || x > 800 || y < 0 || y > 600;
  }

  void handleCollision() {
    // Reduce velocity on collision
    _velocity *= 0.3;

    // Move car back to track (simplified)
    if (_carX < 0) _carX = 10;
    if (_carX > 800) _carX = 790;
    if (_carY < 0) _carY = 10;
    if (_carY > 600) _carY = 590;

    notifyListeners();
  }

  // Utility methods
  double get speedKmh => _currentSpeed * 3.6; // Convert to km/h for display

  String get lapTimeFormatted {
    int minutes = (_currentLapTime / 60).floor();
    double seconds = _currentLapTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(2).padLeft(5, '0')}';
  }

  String get bestLapTimeFormatted {
    if (_bestLapTime == double.infinity) return '--:--.--';
    int minutes = (_bestLapTime / 60).floor();
    double seconds = _bestLapTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(2).padLeft(5, '0')}';
  }
}

// Math utility functions
double cos(double radians) => radians.cos;
double sin(double radians) => radians.sin;
double sqrt(double value) => value.sqrt;
double pow(double base, double exponent) => base.pow(exponent);

extension MathExtensions on double {
  double get cos => this * (3.14159265359 / 180.0);
  double get sin => this * (3.14159265359 / 180.0);
  double get sqrt => this < 0 ? 0 : abs().squareRoot;
  double get squareRoot {
    if (this == 0) return 0;
    double x = this;
    double prev = 0;
    while (x != prev) {
      prev = x;
      x = (x + this / x) / 2;
    }
    return x;
  }

  double pow(double exponent) {
    if (exponent == 0) return 1;
    if (exponent == 1) return this;
    if (exponent == 2) return this * this;
    // Simplified power function for basic needs
    double result = 1;
    for (int i = 0; i < exponent.abs(); i++) {
      result *= this;
    }
    return exponent < 0 ? 1 / result : result;
  }
}
