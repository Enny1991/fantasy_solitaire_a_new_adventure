import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  bool soundEnabled;
  bool musicEnabled;
  bool animationsEnabled;
  bool autoHintEnabled;
  double gameSpeed;

  GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.animationsEnabled = true,
    this.autoHintEnabled = false,
    this.gameSpeed = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'animationsEnabled': animationsEnabled,
        'autoHintEnabled': autoHintEnabled,
        'gameSpeed': gameSpeed,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        soundEnabled: json['soundEnabled'] ?? true,
        musicEnabled: json['musicEnabled'] ?? true,
        animationsEnabled: json['animationsEnabled'] ?? true,
        autoHintEnabled: json['autoHintEnabled'] ?? false,
        gameSpeed: json['gameSpeed']?.toDouble() ?? 1.0,
      );
}

class SettingsService {
  static const String _settingsKey = 'game_settings';
  GameSettings _settings = GameSettings();

  GameSettings get settings => _settings;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = GameSettings.fromJson(json);
      } catch (e) {
        // If there's an error loading settings, use defaults
        _settings = GameSettings();
      }
    }
  }

  Future<void> saveSettings(GameSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  Future<void> updateAutoHint(bool enabled) async {
    _settings.autoHintEnabled = enabled;
    await saveSettings(_settings);
  }

  Future<void> updateSoundEnabled(bool enabled) async {
    _settings.soundEnabled = enabled;
    await saveSettings(_settings);
  }

  Future<void> updateMusicEnabled(bool enabled) async {
    _settings.musicEnabled = enabled;
    await saveSettings(_settings);
  }

  Future<void> updateAnimationsEnabled(bool enabled) async {
    _settings.animationsEnabled = enabled;
    await saveSettings(_settings);
  }

  Future<void> updateGameSpeed(double speed) async {
    _settings.gameSpeed = speed;
    await saveSettings(_settings);
  }
}
