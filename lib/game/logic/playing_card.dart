
enum Suit {
  hearts,
  diamonds,
  clubs,
  spades,
}

enum Rank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

class PlayingCard {
  final Suit suit;
  final Rank rank;
  bool isFaceUp;
  bool isFrozen;

  PlayingCard({
    required this.suit,
    required this.rank,
    this.isFaceUp = false,
    this.isFrozen = false,
  });
}
