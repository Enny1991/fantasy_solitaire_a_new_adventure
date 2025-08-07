
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'player.dart';

class PlayerService {
  static const String _playersKey = 'players';

  Future<List<Player>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getStringList(_playersKey);
    if (playersJson == null) {
      return [];
    }
    return playersJson.map((jsonString) => Player.fromJson(json.decode(jsonString))).toList();
  }

  Future<void> savePlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    final players = await loadPlayers();
    final existingIndex = players.indexWhere((p) => p.name == player.name);
    if (existingIndex != -1) {
      players[existingIndex] = player;
    } else {
      players.add(player);
    }
    final playersJson = players.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }

  Future<Player> createNewPlayer(String name) async {
    final newPlayer = Player(name: name);
    await savePlayer(newPlayer);
    return newPlayer;
  }

  Future<void> deletePlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final players = await loadPlayers();
    players.removeWhere((p) => p.name == name);
    final playersJson = players.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }
}
