
import 'package:flutter/material.dart';
import 'package:fantasy_solitaire_a_new_adventure/game/logic/player.dart';
import 'package:fantasy_solitaire_a_new_adventure/game/logic/player_service.dart';
import 'package:fantasy_solitaire_a_new_adventure/game/screens/main_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  Player? _selectedPlayer;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    _players = await _playerService.loadPlayers();
    setState(() {
      _selectedPlayer = _players.isNotEmpty ? _players.first : null;
    });
  }

  void _createNewPlayer() async {
    final String name = _playerNameController.text.trim();
    if (name.isNotEmpty) {
      final newPlayer = await _playerService.createNewPlayer(name);
      setState(() {
        _players.add(newPlayer);
        _selectedPlayer = newPlayer;
      });
      _startGame();
    }
  }

  void _startGame() {
    if (_selectedPlayer != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigation(player: _selectedPlayer!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Fantasy Solitaire'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_players.isEmpty) ...[
                TextField(
                  controller: _playerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createNewPlayer,
                  child: const Text('Create New Player'),
                ),
              ] else ...[
                DropdownButton<Player>(
                  value: _selectedPlayer,
                  onChanged: (Player? newValue) {
                    setState(() {
                      _selectedPlayer = newValue;
                    });
                  },
                  items: _players.map<DropdownMenuItem<Player>>((Player player) {
                    return DropdownMenuItem<Player>(
                      value: player,
                      child: Text(player.name),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startGame,
                  child: const Text('Start Game'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
