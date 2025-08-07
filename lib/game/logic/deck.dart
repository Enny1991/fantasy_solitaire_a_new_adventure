
import 'dart:math';

import 'playing_card.dart';

class Deck {
  final List<PlayingCard> _cards = [];

  Deck() {
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        _cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  void shuffle() {
    _cards.shuffle(Random());
  }

  PlayingCard deal() {
    return _cards.removeLast();
  }

  List<PlayingCard> dealCards(int count) {
    final List<PlayingCard> cards = [];
    for (int i = 0; i < count; i++) {
      cards.add(deal());
    }
    return cards;
  }

  bool get isEmpty => _cards.isEmpty;
}
