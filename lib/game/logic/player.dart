
import 'power.dart';

class Player {
  String name;
  int level;
  int xp;
  int mana;
  int maxMana;
  double manaRegenRate;
  int gamesWon;
  int gamesPlayed;
  List<Power> unlockedPowers;

  Player({
    required this.name,
    this.level = 1,
    this.xp = 0,
    this.mana = 100,
    this.maxMana = 100,
    this.manaRegenRate = 1.0,
    this.gamesWon = 0,
    this.gamesPlayed = 0,
    List<Power>? unlockedPowers,
  }) : this.unlockedPowers = unlockedPowers ?? [];

  void addXp(int amount) {
    xp += amount;
    // Simple level up logic: 100 XP per level
    if (xp >= level * 100) {
      level++;
      maxMana += 10; // Increase max mana on level up
      manaRegenRate += 0.1; // Increase mana regen rate
      mana = maxMana; // Refill mana on level up
    }
    _checkAndUnlockPowers();
  }

  void _checkAndUnlockPowers() {
    // Define powers and their unlock levels
    final Map<int, Power> levelPowers = {
      1: Power(name: 'Draw Card', description: 'Draw an extra card from the stock', manaCost: 10, type: PowerType.drawCard),
      2: Power(name: 'Shuffle', description: 'Shuffle a tableau pile', manaCost: 20, type: PowerType.shuffle),
      3: Power(name: 'Reveal', description: 'Reveal a face-down card', manaCost: 15, type: PowerType.reveal),
      4: Power(name: 'Remove', description: 'Remove a card from the game', manaCost: 30, type: PowerType.remove),
      5: Power(name: 'Undo', description: 'Undo the last move', manaCost: 5, type: PowerType.undo),
      6: Power(name: 'Freeze', description: 'Freeze a card in place', manaCost: 25, type: PowerType.freeze),
    };

    levelPowers.forEach((unlockLevel, power) {
      if (level >= unlockLevel && !unlockedPowers.any((p) => p.type == power.type)) {
        unlockedPowers.add(power);
      }
    });
  }

  void addPower(Power power) {
    if (!unlockedPowers.contains(power)) {
      unlockedPowers.add(power);
    }
  }

  void recordGameCompletion({required bool won}) {
    gamesPlayed++;
    if (won) {
      gamesWon++;
      addXp(50); // Bonus XP for winning
    } else {
      addXp(10); // Small XP for playing
    }
  }

  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) : 0.0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'xp': xp,
        'mana': mana,
        'maxMana': maxMana,
        'manaRegenRate': manaRegenRate,
        'gamesWon': gamesWon,
        'gamesPlayed': gamesPlayed,
        'unlockedPowers': unlockedPowers.map((p) => p.toJson()).toList(),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'],
        level: json['level'],
        xp: json['xp'],
        mana: json['mana'],
        maxMana: json['maxMana'],
        manaRegenRate: json['manaRegenRate'],
        gamesWon: json['gamesWon'] ?? 0,
        gamesPlayed: json['gamesPlayed'] ?? 0,
        unlockedPowers: (json['unlockedPowers'] as List)
            .map((item) => Power.fromJson(item))
            .toList(),
      );
}
