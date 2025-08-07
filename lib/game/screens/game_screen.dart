
import 'dart:async';
import 'package:flutter/material.dart';

import '../logic/solitaire_game.dart';
import '../logic/playing_card.dart';
import '../logic/power.dart';
import '../logic/player.dart'; // Import the Player class
import '../logic/settings_service.dart';
import 'widgets/playing_card_widget.dart';
import 'widgets/power_widget.dart';

class GameScreen extends StatefulWidget {
  final Player player; // Add player as a final field

  const GameScreen({super.key, required this.player}); // Update constructor

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SolitaireGame _game;
  List<PlayingCard>? _currentlyDraggedCards;
  final SettingsService _settingsService = SettingsService();
  Timer? _hintTimer;
  PlayingCard? _hintedCard;
  List<PlayingCard>? _hintedTargetPile;
  PileType? _hintedTargetPileType;
  int? _hintedTargetPileIndex; // Index of the target pile for highlighting

  @override
  void initState() {
    super.initState();
    _game = SolitaireGame(player: widget.player);
    _game.newGame();
    _settingsService.loadSettings();
    _startHintTimer();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // New Game button at the top
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _resetHintTimer(); // Reset hint timer on new game
                            setState(() {
                              _game.newGame();
                            });
                          },
                          child: const Text('New Game'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Foundation piles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _game.foundationPiles
                          .asMap()
                          .entries
                          .map((entry) => _buildCardPile(
                                entry.value, 
                                PileType.foundation, 
                                pileIndex: entry.key,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    // Tableau piles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _game.tableauPiles
                          .asMap()
                          .entries
                          .map((entry) => _buildCardPile(
                                entry.value, 
                                PileType.tableau, 
                                pileIndex: entry.key,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    // Stock and waste piles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStockPile(),
                        _buildCardPile(_game.waste, PileType.waste),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Player stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Level: ${_game.player.level}'),
                        Text('XP: ${_game.player.xp}'),
                        Text('Mana: ${_game.player.mana}'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Powers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _game.player.unlockedPowers
                          .map((power) => Expanded(
                                child: PowerWidget(
                                  power: power,
                                  onTap: () => _activatePower(power),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildCardPile(List<PlayingCard> pile, PileType pileType, {GlobalKey? key, String? pileId, int? pileIndex}) {
    return DragTarget<List<PlayingCard>>(
      onWillAccept: (data) {
        if (data == null || data.isEmpty) return false;
        return _game.canMoveCards(data, pile, pileType);
      },
      onAccept: (data) {
        _resetHintTimer(); // Reset hint timer on user interaction
        setState(() {
          _game.moveCards(data, pile, pileType);
          _checkGameStatus(); // Check game status after a move
        });
      },
      builder: (context, candidateData, rejectedData) {
        Color borderColor = Colors.black;
        
        // Check if this pile is hinted as a destination
        final bool isHintedDestination = _hintedTargetPile == pile && 
                                          _hintedTargetPileType == pileType;
        
        if (candidateData.isNotEmpty && _game.canMoveCards(candidateData.first!, pile, pileType)) {
          borderColor = Colors.green; // Valid drop
        } else if (rejectedData.isNotEmpty) {
          borderColor = Colors.red; // Invalid drop
        } else if (isHintedDestination) {
          borderColor = Colors.yellow; // Hint destination
        }

        Widget pileContent;
        if (pileType == PileType.tableau) {
          // Fixed maximum height for all tableau piles to prevent layout shifts
          const double maxTableauHeight = 400.0; // Fixed height for all tableau piles
          
          pileContent = SizedBox(
            width: 100, // Fixed width for tableau piles
            height: maxTableauHeight, // Fixed height to prevent layout shifts
            child: pile.isEmpty
                ? Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  )
                : Stack(
                    clipBehavior: Clip.none, // Allow cards to extend beyond the stack
                    children: pile.asMap().entries.map((entry) {
                      int index = entry.key;
                      PlayingCard card = entry.value;
                      
                      // Calculate dynamic spacing based on pile size to fit within max height
                      final double availableHeight = maxTableauHeight - 150.0; // Space for last card
                      final double cardSpacing = pile.length > 1 
                          ? (availableHeight / (pile.length - 1)).clamp(5.0, 25.0) // Min 5px, max 25px spacing
                          : 0.0;
                      
                      // Create a custom widget that handles sub-pile dragging
                      return Positioned(
                        top: index * cardSpacing,
                        left: 0,
                        child: _buildDraggableCard(
                          card: card,
                          dragData: card.isFaceUp ? pile.sublist(index) : [card], // Only drag sub-pile if face-up
                          isDraggable: card.isFaceUp || index == pile.length - 1, // Only face-up cards or last face-down card
                          onCardTap: () {
                            _resetHintTimer(); // Reset hint timer on user interaction
                            if (!card.isFaceUp && index == pile.length - 1) {
                              setState(() {
                                card.isFrozen = false;
                                card.isFaceUp = true;
                              });
                            } else if (card.isFaceUp && index == pile.length - 1) {
                              // Auto-move face-up cards at the top of the pile
                              _autoMoveCard(card);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
          );
        } else {
          // For foundation and waste piles
          pileContent = pile.isEmpty
              ? Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                )
              : Stack(
                  children: [
                    // Show the card underneath if there is one
                    if (pile.length > 1)
                      _buildSingleCard(pile[pile.length - 2]),
                    // Show the top card with dragging capability
                    _buildDraggableCard(
                      card: pile.last,
                      dragData: [pile.last],
                      isDraggable: true,
                      onCardTap: () {
                        _autoMoveCard(pile.last);
                      },
                    ),
                  ],
                );
        }

        // Calculate consistent height for the container
        final double containerHeight = pileType == PileType.tableau 
            ? 400.0 // Fixed height for all tableau piles
            : 150.0;
            
        return Container(
          key: key, // Add the key to the container
          width: 100,
          height: containerHeight,
          alignment: Alignment.topCenter, // Align content to top-center of container
          decoration: pileType == PileType.tableau
              ? BoxDecoration(
                  // No background color for tableau piles - just border
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: borderColor, 
                    width: isHintedDestination ? 3.0 : 2.0,
                  ),
                  boxShadow: isHintedDestination ? [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.8),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ] : null,
                )
              : BoxDecoration(
                  // Keep background for foundation and waste piles
                  color: Colors.green[700], // Base color for the pile
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: borderColor, 
                    width: isHintedDestination ? 3.0 : 2.0,
                  ),
                  boxShadow: isHintedDestination ? [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.8),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green[800]!,
                      Colors.green[600]!,
                    ],
                  ),
                ),
          child: pileContent,
        );
      },
    );
  }

  Widget _buildStockPile() {
    return InkWell(
      onTap: () {
        _resetHintTimer(); // Reset hint timer on user interaction
        setState(() {
          _game.drawCards();
          _checkGameStatus(); // Check game status after drawing cards
        });
      },
      child: Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.brown[700], // Base color for the stock pile
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.brown[800]!,
              Colors.brown[600]!,
            ],
          ),
        ),
        child: _game.stock.isEmpty
            ? Container( // Empty pile placeholder
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )
            : PlayingCardWidget(card: _game.stock.last),
      ),
    );
  }

  void _activatePower(Power power) {
    setState(() {
      final bool activated = _game.activatePower(power);
      if (activated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${power.name} activated!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not enough mana to activate ${power.name}')),
        );
      }
    });
  }

  void _autoMoveCard(PlayingCard card) {
    _resetHintTimer(); // Reset hint timer on user interaction
    
    // Try to find a valid move
    List<PlayingCard>? targetPile;
    PileType? targetPileType;
    
    // Try to move to foundation first
    for (final foundationPile in _game.foundationPiles) {
      if (_game.canMoveCards([card], foundationPile, PileType.foundation)) {
        targetPile = foundationPile;
        targetPileType = PileType.foundation;
        break;
      }
    }
    
    // Then try to move to tableau piles
    if (targetPile == null) {
      for (final tableauPile in _game.tableauPiles) {
        if (_game.canMoveCards([card], tableauPile, PileType.tableau)) {
          targetPile = tableauPile;
          targetPileType = PileType.tableau;
          break;
        }
      }
    }
    
    if (targetPile != null && targetPileType != null) {
      setState(() {
        _game.moveCards([card], targetPile!, targetPileType!);
        _checkGameStatus();
      });
    }
  }

  void _startHintTimer() {
    if (!_settingsService.settings.autoHintEnabled) return;
    
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 5), () {
      _showHint();
    });
  }

  void _resetHintTimer() {
    _clearHint();
    _startHintTimer();
  }

  void _showHint() {
    if (!_settingsService.settings.autoHintEnabled) return;
    
    final hint = _findPossibleMove();
    if (hint != null) {
      setState(() {
        _hintedCard = hint['card'];
        _hintedTargetPile = hint['targetPile'];
        _hintedTargetPileType = hint['targetPileType'];
      });
      
      // Show hint for 3 seconds then clear it
      Timer(const Duration(seconds: 3), () {
        _clearHint();
        _startHintTimer(); // Restart timer for next hint
      });
    } else {
      // No moves found, restart timer to check again later
      _startHintTimer();
    }
  }

  void _clearHint() {
    if (_hintedCard != null) {
      setState(() {
        _hintedCard = null;
        _hintedTargetPile = null;
        _hintedTargetPileType = null;
        _hintedTargetPileIndex = null;
      });
    }
  }

  Map<String, dynamic>? _findPossibleMove() {
    // Check waste pile for possible moves
    if (_game.waste.isNotEmpty) {
      final wasteCard = _game.waste.last;
      
      // Try foundation first
      for (final foundationPile in _game.foundationPiles) {
        if (_game.canMoveCards([wasteCard], foundationPile, PileType.foundation)) {
          return {
            'card': wasteCard,
            'targetPile': foundationPile,
            'targetPileType': PileType.foundation,
          };
        }
      }
      
      // Try tableau piles
      for (final tableauPile in _game.tableauPiles) {
        if (_game.canMoveCards([wasteCard], tableauPile, PileType.tableau)) {
          return {
            'card': wasteCard,
            'targetPile': tableauPile,
            'targetPileType': PileType.tableau,
          };
        }
      }
    }
    
    // Check tableau piles for possible moves
    for (final sourcePile in _game.tableauPiles) {
      if (sourcePile.isEmpty) continue;
      
      // Check if top card is face-down and can be flipped
      final topCard = sourcePile.last;
      if (!topCard.isFaceUp) {
        return {
          'card': topCard,
          'targetPile': sourcePile, // Same pile (flip in place)
          'targetPileType': PileType.tableau,
        };
      }
      
      // Find sequences of face-up cards that can be moved
      for (int i = sourcePile.length - 1; i >= 0; i--) {
        final card = sourcePile[i];
        if (!card.isFaceUp) break;
        
        // Try to move this card (and all cards above it) to foundation
        if (i == sourcePile.length - 1) { // Only single cards to foundation
          for (final foundationPile in _game.foundationPiles) {
            if (_game.canMoveCards([card], foundationPile, PileType.foundation)) {
              return {
                'card': card,
                'targetPile': foundationPile,
                'targetPileType': PileType.foundation,
              };
            }
          }
        }
        
        // Try to move to other tableau piles
        final cardsToMove = sourcePile.sublist(i);
        for (final targetPile in _game.tableauPiles) {
          if (targetPile == sourcePile) continue;
          if (_game.canMoveCards(cardsToMove, targetPile, PileType.tableau)) {
            return {
              'card': card,
              'targetPile': targetPile,
              'targetPileType': PileType.tableau,
            };
          }
        }
      }
    }
    
    return null; // No moves found
  }
  

  void _checkGameStatus() {
    if (_game.isGameWon()) {
      _showGameResultDialog('You Win!', '''Congratulations! You've cleared all the cards.''');
    } else if (_game.isGameOver()) {
      _showGameResultDialog('Game Over', 'No more moves left. Try again!');
    }
  }

  void _showGameResultDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('New Game'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _game.newGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableCard({
    required PlayingCard card,
    required List<PlayingCard> dragData,
    required VoidCallback onCardTap,
    required bool isDraggable,
  }) {
    // If the card is not draggable, just return a tap-able card
    if (!isDraggable) {
      return GestureDetector(
        onTap: onCardTap,
        child: _shouldHideCard(card) ? Container() : _buildSingleCard(card),
      );
    }
    
    // If it's draggable, return a draggable card
    return GestureDetector(
      onTap: onCardTap,
      child: Draggable<List<PlayingCard>>(
        data: dragData,
        feedback: Material(
          color: Colors.transparent,
          child: _buildCardStack(dragData),
        ),
        childWhenDragging: Container(), // Completely hide the original card when dragging
        onDragStarted: () {
          _resetHintTimer(); // Reset hint timer on drag start
          setState(() {
            _currentlyDraggedCards = dragData;
          });
        },
        onDragEnd: (details) {
          // Immediately restore card visibility
          setState(() {
            _currentlyDraggedCards = null;
          });
        },
        child: _shouldHideCard(card) ? Container() : _buildSingleCard(card),
      ),
    );
  }

  bool _shouldHideCard(PlayingCard card) {
    if (_currentlyDraggedCards == null) return false;
    return _currentlyDraggedCards!.contains(card);
  }

  Widget _buildSingleCard(PlayingCard card) {
    // Check if this card is being hinted
    final bool isHinted = _hintedCard == card;
    
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(
          color: card.isFrozen ? Colors.red : (isHinted ? Colors.yellow : Colors.black),
          width: isHinted ? 3.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: isHinted ? [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.8),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ] : null,
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
            child: _buildSingleCard(card),
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
