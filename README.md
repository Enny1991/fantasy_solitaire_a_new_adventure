# fantasy_solitaire_a_new_adventure

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 📜 Elemental Powers - Game Design Document

## Overview

In this solitaire-RPG hybrid, players unlock and wield elemental powers to manipulate the game board in new strategic ways. Powers are grouped into five elemental types—Fire, Water, Earth, Thunder, and Time—and each type has three upgrade levels. Higher levels grant more powerful effects but require more mana.

---

## 🔥 Fire – Destruction & Risk

**Theme:** Burn away obstacles to reveal new possibilities.
**Primary Mechanic:** Remove or destroy cards to reveal new options.

| Level | Name   | Effect                                                                     |
| ----- | ------ | -------------------------------------------------------------------------- |
| I     | Fire   | Burn 1 face-down tableau card to reveal it immediately.                    |
| II    | Fira   | Burn 1 full column of tableau cards, revealing all face-down cards in it.  |
| III   | Firaga | Burn up to 3 selected tableau cards anywhere on the board, even if buried. |

---

## 💧 Water – Flow & Control

**Theme:** Reshaping card order and flow.
**Primary Mechanic:** Swap or move cards outside normal rules.

| Level | Name    | Effect                                                                               |
| ----- | ------- | ------------------------------------------------------------------------------------ |
| I     | Water   | Swap two face-up cards in the tableau.                                               |
| II    | Watra   | Temporarily unfreeze a card and move it anywhere on the tableau regardless of color. |
| III   | Watraga | Freely rearrange an entire column or any two tableau stacks.                         |

---

## 🌱 Earth – Protection & Stability

**Theme:** Defensive support for long-term strategy.
**Primary Mechanic:** Keep key cards safe and accessible.

| Level | Name    | Effect                                                                      |
| ----- | ------- | --------------------------------------------------------------------------- |
| I     | Earth   | Anchor a face-up card so it cannot be buried or moved accidentally.         |
| II    | Earthra | Anchor a full tableau column for 3 turns, preventing reshuffling or burial. |
| III   | Earthga | Anchor up to 3 cards permanently, making them always visible and movable.   |

---

## ⚡ Thunder – Surprise & Chaos

**Theme:** Shake the board state with unpredictable energy.
**Primary Mechanic:** Random reveal or reshuffle for high-risk/high-reward plays.

| Level | Name     | Effect                                                         |
| ----- | -------- | -------------------------------------------------------------- |
| I     | Thunder  | Reveal a random hidden card from the tableau.                  |
| II    | Thundra  | Shuffle a tableau column, randomizing the card order.          |
| III   | Thundaga | Reroll the draw pile with a new temporary deck of higher odds. |

---

## ⏳ Time – Undo & Rewind

**Theme:** Rewind gameplay to recover from mistakes.
**Primary Mechanic:** Undo moves or replay previous states.

| Level | Name  | Effect                                                             |
| ----- | ----- | ------------------------------------------------------------------ |
| I     | Haste | Undo the last move, even if it broke the rules.                    |
| II    | Slow  | Rewind the last 3 moves (history-based undo).                      |
| III   | Stop  | Rewind the game state to any earlier point in the current session. |

---

## Summary Table

| Element | Focus       | Level I        | Level II       | Level III            |
| ------- | ----------- | -------------- | -------------- | -------------------- |
| Fire    | Destruction | Reveal 1 card  | Burn column    | Remove any 3 cards   |
| Water   | Control     | Swap 2 cards   | Free move      | Rearrange columns    |
| Earth   | Protection  | Anchor 1 card  | Anchor column  | Anchor 3 cards       |
| Thunder | Chaos       | Reveal random  | Shuffle column | Reroll draw pile     |
| Time    | Undo/Rewind | Undo last move | Rewind 3 moves | Rewind to checkpoint |

---

## Design Notes

* **Balance:** Time and Water offer strong utility for escaping checkmates. Fire and Thunder offer tactical resets. Earth is ideal for long-term planning.
* **Cost Scaling:** Higher-tier powers should cost more mana and/or have cooldowns.
* **Progression:** Unlock powers via XP. Mana limits usage per game.
* **Synergies:** Players can combo elemental effects for strategic depth (e.g. Earth-anchor a card, then Fire-burn others).

