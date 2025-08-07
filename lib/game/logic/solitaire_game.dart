
import 'dart:math';

import 'package:fantasy_solitaire_a_new_adventure/game/logic/player_service.dart';

import 'deck.dart';
import 'playing_card.dart';
import 'player.dart';
import 'power.dart';
import 'game_state.dart';

enum PileType {
  tableau,
  foundation,
  stock,
  waste,
}

class SolitaireGame {
  final Player player;
  final PlayerService _playerService = PlayerService();
  final List<List<PlayingCard>> tableauPiles = List.generate(7, (_) => []);
  final List<List<PlayingCard>> foundationPiles = List.generate(4, (_) => []);
  final List<PlayingCard> stock = [];
  final List<PlayingCard> waste = [];

  final Deck _deck = Deck();
  final List<GameState> _history = [];

  SolitaireGame({required this.player});

  void newGame() {
    // Clear all the piles
    tableauPiles.forEach((pile) => pile.clear());
    foundationPiles.forEach((pile) => pile.clear());
    stock.clear();
    waste.clear();

    // Shuffle the deck
    _deck.shuffle();

    // Deal the cards to the tableau piles
    for (int i = 0; i < 7; i++) {
      for (int j = i; j < 7; j++) {
        final card = _deck.deal();
        if (j == i) {
          card.isFaceUp = true;
        }
        tableauPiles[j].add(card);
      }
    }

    // Add the remaining cards to the stock
    while (!_deck.isEmpty) {
      stock.add(_deck.deal());
    }
    _saveState();
  }

  bool canMoveCards(List<PlayingCard> cards, List<PlayingCard> toPile, PileType toPileType) {
    if (cards.isEmpty) {
      return false;
    }

    final firstCard = cards.first;
    if (!firstCard.isFaceUp || firstCard.isFrozen) {
      return false;
    }

    // Ensure all cards in the stack are face-up
    if (cards.any((card) => !card.isFaceUp)) {
      return false;
    }

    switch (toPileType) {
      case PileType.foundation:
        if (cards.length > 1) return false; // Only single cards to foundation
        if (toPile.isEmpty) {
          return firstCard.rank == Rank.ace;
        } else {
          final topCard = toPile.last;
          return firstCard.suit == topCard.suit && firstCard.rank.index == topCard.rank.index + 1;
        }
      case PileType.tableau:
        if (toPile.isEmpty) {
          return firstCard.rank == Rank.king;
        } else {
          final topCard = toPile.last;
          return _isOppositeColor(firstCard, topCard) && firstCard.rank.index == topCard.rank.index - 1;
        }
      case PileType.waste:
        if (cards.length > 1) return false; // Only single cards from waste
        return true; // Can always move from waste to tableau or foundation (handled by those piles)
      case PileType.stock:
        return false; // Cannot move cards to stock
    }
  }

  void moveCards(List<PlayingCard> cards, List<PlayingCard> toPile, PileType toPileType) {
    if (cards.isEmpty) return;

    _saveState();

    final fromPileAndIndex = _findCardPileAndIndex(cards.first);
    if (fromPileAndIndex == null) return; // Card not found in any pile

    final fromPile = fromPileAndIndex.item1;
    final startIndex = fromPileAndIndex.item2;

    // Remove cards from the original pile
    final cardsToMove = fromPile.sublist(startIndex);
    fromPile.removeRange(startIndex, fromPile.length);

    // Add cards to the destination pile
    toPile.addAll(cardsToMove);

    // Flip the new top card of the original pile if it's face down
    if (fromPile.isNotEmpty && !fromPile.last.isFaceUp) {
      fromPile.last.isFaceUp = true;
    }

    // Award XP for the move
    player.addXp(10 * cards.length); // Award XP based on number of cards moved
  }

  void drawCards() {
    _saveState();
    if (stock.isEmpty) {
      stock.addAll(waste.reversed);
      waste.clear();
    } else {
      final card = stock.removeLast();
      card.isFaceUp = true;
      waste.add(card);
    }
  }

  bool activatePower(Power power) {
    if (player.mana >= power.manaCost) {
      player.mana -= power.manaCost;
      switch (power.type) {
        case PowerType.drawCard:
          drawCards();
          break;
        case PowerType.shuffle:
          _shuffleRandomTableauPile();
          break;
        case PowerType.reveal:
          _revealRandomFaceDownCard();
          break;
        case PowerType.remove:
          _removeRandomWasteCard();
          break;
        case PowerType.undo:
          _undoLastMove();
          break;
        case PowerType.freeze:
          // TODO: Implement freeze logic
          print('Freeze power activated (not yet implemented)');
          break;
      }
      _playerService.savePlayer(player);
      return true;
    }
    return false;
  }

  void _saveState() {
    _history.add(GameState(
      tableauPiles: tableauPiles.map((pile) => List<PlayingCard>.from(pile)).toList(),
      foundationPiles: foundationPiles.map((pile) => List<PlayingCard>.from(pile)).toList(),
      stock: List<PlayingCard>.from(stock),
      waste: List<PlayingCard>.from(waste),
    ));
  }

  void _undoLastMove() {
    if (_history.length > 1) {
      _history.removeLast(); // Remove current state
      final previousState = _history.last; // Get previous state

      // Restore state
      for (int i = 0; i < tableauPiles.length; i++) {
        tableauPiles[i] = List<PlayingCard>.from(previousState.tableauPiles[i]);
      }
      for (int i = 0; i < foundationPiles.length; i++) {
        foundationPiles[i] = List<PlayingCard>.from(previousState.foundationPiles[i]);
      }
      stock.clear();
      stock.addAll(previousState.stock);
      waste.clear();
      waste.addAll(previousState.waste);
    }
  }

  void _shuffleRandomTableauPile() {
    final random = Random();
    final targetPileIndex = random.nextInt(tableauPiles.length);
    final targetPile = tableauPiles[targetPileIndex];

    final faceDownCards = targetPile.where((card) => !card.isFaceUp).toList();
    faceDownCards.shuffle(random);

    int faceDownIndex = 0;
    for (int i = 0; i < targetPile.length; i++) {
      if (!targetPile[i].isFaceUp) {
        targetPile[i] = faceDownCards[faceDownIndex++];
      }
    }
  }

  void _revealRandomFaceDownCard() {
    final random = Random();
    final allFaceDownCards = <PlayingCard>[];
    for (final pile in tableauPiles) {
      allFaceDownCards.addAll(pile.where((card) => !card.isFaceUp));
    }

    if (allFaceDownCards.isNotEmpty) {
      final cardToReveal = allFaceDownCards[random.nextInt(allFaceDownCards.length)];
      cardToReveal.isFaceUp = true;
    }
  }

  void _removeRandomWasteCard() {
    if (waste.isNotEmpty) {
      waste.removeLast();
    }
  }

  void _freezeRandomCard() {
    final random = Random();
    final allCards = <PlayingCard>[];
    for (final pile in tableauPiles) {
      allCards.addAll(pile.where((card) => card.isFaceUp && !card.isFrozen));
    }
    if (waste.isNotEmpty) {
      allCards.addAll(waste.where((card) => card.isFaceUp && !card.isFrozen));
    }

    if (allCards.isNotEmpty) {
      final cardToFreeze = allCards[random.nextInt(allCards.length)];
      cardToFreeze.isFrozen = true;
    }
  }

  Tuple<List<PlayingCard>, int>? _findCardPileAndIndex(PlayingCard card) {
    for (final pile in tableauPiles) {
      final index = pile.indexOf(card);
      if (index != -1) {
        return Tuple(pile, index);
      }
    }
    for (final pile in foundationPiles) {
      final index = pile.indexOf(card);
      if (index != -1) {
        return Tuple(pile, index);
      }
    }
    if (stock.contains(card)) {
      return Tuple(stock, stock.indexOf(card));
    }
    if (waste.contains(card)) {
      return Tuple(waste, waste.indexOf(card));
    }
    return null;
  }

  bool _isOppositeColor(PlayingCard card1, PlayingCard card2) {
    if ((card1.suit == Suit.hearts || card1.suit == Suit.diamonds) &&
        (card2.suit == Suit.clubs || card2.suit == Suit.spades)) {
      return true;
    }
    if ((card1.suit == Suit.clubs || card1.suit == Suit.spades) &&
        (card2.suit == Suit.hearts || card2.suit == Suit.diamonds)) {
      return true;
    }
    return false;
  }

  bool isGameWon() {
    return foundationPiles.every((pile) => pile.length == 13);
  }

  bool isGameOver() {
    // Game is over if no more moves are possible
    // This is a simplified check and can be expanded for more complex scenarios
    return !tableauPiles.any((pile) => pile.any((card) => card.isFaceUp && !card.isFrozen)) &&
           stock.isEmpty &&
           waste.isEmpty;
  }

  // Hint system methods
  HintMove? findPossibleMove() {
    // Try to find moves from waste to foundation or tableau
    if (waste.isNotEmpty) {
      final wasteCard = waste.last;
      if (wasteCard.isFaceUp && !wasteCard.isFrozen) {
        // Try foundation piles
        for (int i = 0; i < foundationPiles.length; i++) {
          if (canMoveCards([wasteCard], foundationPiles[i], PileType.foundation)) {
            return HintMove(
              sourceCard: wasteCard,
              sourcePile: waste,
              targetPile: foundationPiles[i],
              pileType: PileType.foundation,
              pileIndex: i,
            );
          }
        }
        // Try tableau piles
        for (int i = 0; i < tableauPiles.length; i++) {
          if (canMoveCards([wasteCard], tableauPiles[i], PileType.tableau)) {
            return HintMove(
              sourceCard: wasteCard,
              sourcePile: waste,
              targetPile: tableauPiles[i],
              pileType: PileType.tableau,
              pileIndex: i,
            );
          }
        }
      }
    }

    // Try to find moves from tableau piles
    for (int sourceIndex = 0; sourceIndex < tableauPiles.length; sourceIndex++) {
      final sourcePile = tableauPiles[sourceIndex];
      if (sourcePile.isEmpty) continue;

      // Check each face-up card in the pile
      for (int cardIndex = 0; cardIndex < sourcePile.length; cardIndex++) {
        final card = sourcePile[cardIndex];
        if (!card.isFaceUp || card.isFrozen) continue;

        final cardsToMove = sourcePile.sublist(cardIndex);
        
        // Try foundation piles (only single cards)
        if (cardsToMove.length == 1) {
          for (int targetIndex = 0; targetIndex < foundationPiles.length; targetIndex++) {
            if (canMoveCards(cardsToMove, foundationPiles[targetIndex], PileType.foundation)) {
              return HintMove(
                sourceCard: card,
                sourcePile: sourcePile,
                targetPile: foundationPiles[targetIndex],
                pileType: PileType.foundation,
                pileIndex: targetIndex,
                sourceIndex: sourceIndex,
              );
            }
          }
        }

        // Try other tableau piles
        for (int targetIndex = 0; targetIndex < tableauPiles.length; targetIndex++) {
          if (targetIndex == sourceIndex) continue;
          if (canMoveCards(cardsToMove, tableauPiles[targetIndex], PileType.tableau)) {
            return HintMove(
              sourceCard: card,
              sourcePile: sourcePile,
              targetPile: tableauPiles[targetIndex],
              pileType: PileType.tableau,
              pileIndex: targetIndex,
              sourceIndex: sourceIndex,
            );
          }
        }
      }
    }

    return null; // No possible moves found
  }
}

// Simple Tuple class for returning multiple values
class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(this.item1, this.item2);
}

// Hint move class for the hint system
class HintMove {
  final PlayingCard sourceCard;
  final List<PlayingCard> sourcePile;
  final List<PlayingCard> targetPile;
  final PileType pileType;
  final int pileIndex; // Index of target pile
  final int? sourceIndex; // Index of source pile (for tableau)

  HintMove({
    required this.sourceCard,
    required this.sourcePile,
    required this.targetPile,
    required this.pileType,
    required this.pileIndex,
    this.sourceIndex,
  });
}
