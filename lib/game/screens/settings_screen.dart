import 'package:flutter/material.dart';
import '../logic/player.dart';
import '../logic/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final Player player;

  const SettingsScreen({super.key, required this.player});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _animationsEnabled = true;
  bool _autoHintEnabled = false;
  double _gameSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.loadSettings();
    setState(() {
      _soundEnabled = _settingsService.settings.soundEnabled;
      _musicEnabled = _settingsService.settings.musicEnabled;
      _animationsEnabled = _settingsService.settings.animationsEnabled;
      _autoHintEnabled = _settingsService.settings.autoHintEnabled;
      _gameSpeed = _settingsService.settings.gameSpeed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false, // Remove back button since we're using bottom nav
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Game Settings Section
          _buildSectionHeader('Game Settings'),
          Card(
            elevation: 4,
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Auto Hint',
                  subtitle: 'Show hints for possible moves',
                  value: _autoHintEnabled,
                  icon: Icons.lightbulb_outline,
                  onChanged: (value) async {
                    setState(() {
                      _autoHintEnabled = value;
                    });
                    await _settingsService.updateAutoHint(value);
                  },
                ),
                const Divider(height: 1),
                _buildSliderTile(
                  title: 'Game Speed',
                  subtitle: 'Adjust animation and move speed',
                  value: _gameSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 3,
                  icon: Icons.speed,
                  onChanged: (value) async {
                    setState(() {
                      _gameSpeed = value;
                    });
                    await _settingsService.updateGameSpeed(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Audio Settings Section
          _buildSectionHeader('Audio Settings'),
          Card(
            elevation: 4,
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Sound Effects',
                  subtitle: 'Enable card flip and move sounds',
                  value: _soundEnabled,
                  icon: Icons.volume_up,
                  onChanged: (value) async {
                    setState(() {
                      _soundEnabled = value;
                    });
                    await _settingsService.updateSoundEnabled(value);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Background Music',
                  subtitle: 'Play ambient fantasy music',
                  value: _musicEnabled,
                  icon: Icons.music_note,
                  onChanged: (value) async {
                    setState(() {
                      _musicEnabled = value;
                    });
                    await _settingsService.updateMusicEnabled(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Display Settings Section
          _buildSectionHeader('Display Settings'),
          Card(
            elevation: 4,
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Animations',
                  subtitle: 'Enable card movement animations',
                  value: _animationsEnabled,
                  icon: Icons.animation,
                  onChanged: (value) async {
                    setState(() {
                      _animationsEnabled = value;
                    });
                    await _settingsService.updateAnimationsEnabled(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Account Settings Section
          _buildSectionHeader('Account Settings'),
          Card(
            elevation: 4,
            child: Column(
              children: [
                _buildActionTile(
                  title: 'Change Player Name',
                  subtitle: 'Currently: ${widget.player.name}',
                  icon: Icons.edit,
                  onTap: () {
                    _showChangeNameDialog();
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Reset Progress',
                  subtitle: 'Clear all stats and achievements',
                  icon: Icons.refresh,
                  iconColor: Colors.orange[600],
                  onTap: () {
                    _showResetProgressDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About Section
          _buildSectionHeader('About'),
          Card(
            elevation: 4,
            child: Column(
              children: [
                _buildActionTile(
                  title: 'Version',
                  subtitle: '1.0.0',
                  icon: Icons.info,
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  icon: Icons.privacy_tip,
                  onTap: () {
                    _showPrivacyDialog();
                  },
                ),
                const Divider(height: 1),
                _buildActionTile(
                  title: 'About Fantasy Solitaire',
                  subtitle: 'Learn more about the game',
                  icon: Icons.help_outline,
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40), // Extra space at bottom
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.blue[600],
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[600],
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue[600],
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: '${value.toStringAsFixed(1)}x',
            onChanged: onChanged,
            activeColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.blue[600],
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangeNameDialog() {
    final TextEditingController controller = TextEditingController(
      text: widget.player.name,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Player Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Enter new name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != widget.player.name) {
                  setState(() {
                    widget.player.name = newName;
                    // TODO: Save player data
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name updated successfully!')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showResetProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Progress'),
          content: const Text(
            'Are you sure you want to reset all your progress? This action cannot be undone.\n\n'
            'This will reset:\n'
            '• Level and XP\n'
            '• Games won/played statistics\n'
            '• Unlocked powers\n'
            '• Achievement progress',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.player.level = 1;
                  widget.player.xp = 0;
                  widget.player.gamesWon = 0;
                  widget.player.gamesPlayed = 0;
                  widget.player.unlockedPowers.clear();
                  // TODO: Save player data and reset achievements
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress reset successfully!')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'Fantasy Solitaire: A New Adventure\n\n'
              'This game stores your progress locally on your device. '
              'We do not collect, store, or share any personal information.\n\n'
              'Data collected:\n'
              '• Game statistics (wins, losses, level)\n'
              '• Player preferences and settings\n'
              '• Achievement progress\n\n'
              'All data remains on your device and is never transmitted to external servers.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Fantasy Solitaire'),
          content: const SingleChildScrollView(
            child: Text(
              'Fantasy Solitaire: A New Adventure\n\n'
              'A magical twist on the classic Klondike Solitaire game. '
              'Progress through levels, unlock mystical powers, and become '
              'the ultimate solitaire master!\n\n'
              'Features:\n'
              '• Classic Klondike Solitaire gameplay\n'
              '• RPG-style progression system\n'
              '• Magical powers to aid your journey\n'
              '• Achievements to unlock\n'
              '• Beautiful fantasy theme\n\n'
              'Developed with Flutter and lots of ❤️',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
