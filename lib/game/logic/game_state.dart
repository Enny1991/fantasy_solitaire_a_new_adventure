
import 'playing_card.dart';

class GameState {
  final List<List<PlayingCard>> tableauPiles;
  final List<List<PlayingCard>> foundationPiles;
  final List<PlayingCard> stock;
  final List<PlayingCard> waste;

  GameState({
    required this.tableauPiles,
    required this.foundationPiles,
    required this.stock,
    required this.waste,
  });

  // Helper to create a deep copy of the game state
  factory GameState.copy(GameState original) {
    return GameState(
      tableauPiles: original.tableauPiles.map((pile) => List<PlayingCard>.from(pile)).toList(),
      foundationPiles: original.foundationPiles.map((pile) => List<PlayingCard>.from(pile)).toList(),
      stock: List<PlayingCard>.from(original.stock),
      waste: List<PlayingCard>.from(original.waste),
    );
  }
}
