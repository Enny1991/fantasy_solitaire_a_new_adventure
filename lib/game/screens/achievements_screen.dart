import 'package:flutter/material.dart';
import '../logic/player.dart';

class Achievement {
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int? requirement;
  final String? requirementText;

  Achievement({
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.requirement,
    this.requirementText,
  });
}

class AchievementsScreen extends StatefulWidget {
  final Player player;

  const AchievementsScreen({super.key, required this.player});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> get achievements => [
    Achievement(
      name: 'First Steps',
      description: 'Complete your first game',
      icon: Icons.play_circle_outline,
      isUnlocked: widget.player.gamesPlayed >= 1,
      requirement: 1,
      requirementText: 'Play 1 game',
    ),
    Achievement(
      name: 'Winner Winner',
      description: 'Win your first game',
      icon: Icons.emoji_events,
      isUnlocked: widget.player.gamesWon >= 1,
      requirement: 1,
      requirementText: 'Win 1 game',
    ),
    Achievement(
      name: 'Getting the Hang of It',
      description: 'Win 5 games',
      icon: Icons.trending_up,
      isUnlocked: widget.player.gamesWon >= 5,
      requirement: 5,
      requirementText: 'Win 5 games',
    ),
    Achievement(
      name: 'Solitaire Master',
      description: 'Win 25 games',
      icon: Icons.military_tech,
      isUnlocked: widget.player.gamesWon >= 25,
      requirement: 25,
      requirementText: 'Win 25 games',
    ),
    Achievement(
      name: 'Legendary Player',
      description: 'Win 100 games',
      icon: Icons.workspace_premium,
      isUnlocked: widget.player.gamesWon >= 100,
      requirement: 100,
      requirementText: 'Win 100 games',
    ),
    Achievement(
      name: 'Level Up!',
      description: 'Reach level 5',
      icon: Icons.star,
      isUnlocked: widget.player.level >= 5,
      requirement: 5,
      requirementText: 'Reach level 5',
    ),
    Achievement(
      name: 'Rising Star',
      description: 'Reach level 10',
      icon: Icons.star_border,
      isUnlocked: widget.player.level >= 10,
      requirement: 10,
      requirementText: 'Reach level 10',
    ),
    Achievement(
      name: 'Power User',
      description: 'Unlock your first power',
      icon: Icons.auto_fix_high,
      isUnlocked: widget.player.unlockedPowers.isNotEmpty,
      requirement: 1,
      requirementText: 'Unlock 1 power',
    ),
    Achievement(
      name: 'Persistent Player',
      description: 'Play 50 games',
      icon: Icons.games,
      isUnlocked: widget.player.gamesPlayed >= 50,
      requirement: 50,
      requirementText: 'Play 50 games',
    ),
    Achievement(
      name: 'Win Streak',
      description: 'Maintain a 70% win rate with at least 10 games played',
      icon: Icons.local_fire_department,
      isUnlocked: widget.player.gamesPlayed >= 10 && 
                  (widget.player.gamesWon / widget.player.gamesPlayed) >= 0.7,
      requirementText: '70% win rate (10+ games)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements = achievements.where((a) => !a.isUnlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        automaticallyImplyLeading: false, // Remove back button since we're using bottom nav
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievement Progress',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${unlockedAchievements.length}/${achievements.length} unlocked',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: unlockedAchievements.length / achievements.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Unlocked Achievements
            if (unlockedAchievements.isNotEmpty) ...[
              Text(
                'Unlocked Achievements',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...unlockedAchievements.map((achievement) => 
                _buildAchievementCard(achievement, true)
              ),
              const SizedBox(height: 24),
            ],

            // Locked Achievements
            if (lockedAchievements.isNotEmpty) ...[
              Text(
                'Locked Achievements',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...lockedAchievements.map((achievement) => 
                _buildAchievementCard(achievement, false)
              ),
            ],

            if (unlockedAchievements.isEmpty && lockedAchievements.isEmpty)
              const Center(
                child: Text('No achievements available'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Card(
      elevation: isUnlocked ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [Colors.amber[50]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.amber[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  achievement.icon,
                  color: isUnlocked ? Colors.amber[700] : Colors.grey[500],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
                      ),
                    ),
                    if (!isUnlocked && achievement.requirementText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Requirement: ${achievement.requirementText}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (achievement.requirement != null) ...[
                        const SizedBox(height: 8),
                        _buildProgressBar(achievement),
                      ],
                    ],
                  ],
                ),
              ),
              if (isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(Achievement achievement) {
    if (achievement.requirement == null) return Container();

    double progress = 0.0;
    int current = 0;

    // Determine current progress based on achievement type
    if (achievement.name.contains('game') && achievement.name.contains('Win')) {
      current = widget.player.gamesWon;
    } else if (achievement.name.contains('Play')) {
      current = widget.player.gamesPlayed;
    } else if (achievement.name.contains('level')) {
      current = widget.player.level;
    } else if (achievement.name.contains('power')) {
      current = widget.player.unlockedPowers.length;
    }

    progress = (current / achievement.requirement!).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$current / ${achievement.requirement}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
        ),
      ],
    );
  }
}
