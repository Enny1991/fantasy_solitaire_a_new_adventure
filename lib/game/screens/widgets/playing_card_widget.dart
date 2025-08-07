import 'package:flutter/material.dart';

import '../../logic/playing_card.dart';

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final List<PlayingCard>? dragData;
  final VoidCallback? onCardTap;
  final bool isBeingDragged;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.dragData,
    this.onCardTap,
    this.isBeingDragged = false,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Draggable<List<PlayingCard>>(
        data: dragData ?? [card],
        feedback: Material(
          color: Colors.transparent,
          child: _buildCardStack(dragData ?? [card]),
        ),
        childWhenDragging: Container(),
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: card.isFrozen ? Colors.red : Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: card.isFaceUp
          ? Image.asset(_getCardImagePath(card))
          : Image.asset('assets/cards/back.png'), // Generic card back
    );
  }

  Widget _buildCardStack(List<PlayingCard> cards) {
    return SizedBox(
      width: 100,
      height: (cards.length * 25.0) + 130, // Dynamic height based on number of cards - match pile spacing
      child: Stack(
        children: cards.asMap().entries.map((entry) {
          int index = entry.key;
          PlayingCard card = entry.value;
          return Positioned(
            top: index * 25.0, // Use consistent 25px spacing to match pile spacing
            child: PlayingCardWidget(
              card: card,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCardImagePath(PlayingCard card) {
    String rank = card.rank.toString().split('.').last;
    String suit = card.suit.toString().split('.').last;

    // Map rank and suit to image file names based on the old project's naming convention
    // This is a simplified mapping and might need adjustments based on actual image names
    String rankChar;
    switch (rank) {
      case 'ace':
        rankChar = 'a';
        break;
      case 'two':
        rankChar = 'due';
        break;
      case 'three':
        rankChar = 'tre';
        break;
      case 'four':
        rankChar = 'quattro';
        break;
      case 'five':
        rankChar = 'cinque';
        break;
      case 'six':
        rankChar = 'sei';
        break;
      case 'seven':
        rankChar = 'sette';
        break;
      case 'eight':
        rankChar = 'otto';
        break;
      case 'nine':
        rankChar = 'nove';
        break;
      case 'ten':
        rankChar = 'dieci';
        break;
      case 'jack':
        rankChar = 'j';
        break;
      case 'queen':
        rankChar = 'q';
        break;
      case 'king':
        rankChar = 'k';
        break;
      default:
        rankChar = '';
    }

    String suitChar;
    switch (suit) {
      case 'clubs':
        suitChar = 'c';
        break;
      case 'diamonds':
        suitChar = 'f'; // Assuming 'f' for diamonds based on old project's 'diecif.png'
        break;
      case 'hearts':
        suitChar = 'p'; // Assuming 'p' for hearts based on old project's 'diecip.png'
        break;
      case 'spades':
        suitChar = 'q'; // Assuming 'q' for spades based on old project's 'dieciq.png'
        break;
      default:
        suitChar = '';
    }

    return 'assets/cards/$rankChar$suitChar.png';
  }
}
