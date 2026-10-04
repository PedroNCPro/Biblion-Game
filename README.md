# Biblion-Game

Final project for the Human-Computer Interaction course at Télécom Paris.

## Overview

Biblion is a word-based puzzle game inspired by classic word-guessing games, but with a richer board and a progression system. The player solves a hidden word by filling a grid row by row, while the game evaluates each guess, rewards the player with points, and triggers special letter effects that can boost the score or modify the board.

## Running the game

This game is a GODOT project, hence GODOT should be use to run the game or export it as an executable file.

The game is not completely finished and might present instability on higher levels.

## Core gameplay

The player starts from the main menu and launches a run. Each run is made of several levels.

1. A level is created from a generated grid.
2. The last row of the grid defines the possible letters of the secret word.
3. The game picks a hidden word from the dictionary that matches the size of that final row.
4. The player types letters using the on-screen keyboard or keyboard input.
5. When a row is complete, the game validates the guess and compares each letter to the secret word.

### Guess evaluation

Each letter in a submitted guess is marked as:

- Green: the letter is in the secret word and in the correct position.
- Yellow: the letter is in the secret word but in the wrong position.
- Grey: the letter is not present in the secret word.

The game also awards points:

- Correct letter: +10
- Misplaced letter: +5
- Wrong letter: +1

The score is then modified by bonuses and special effects, such as diacritics and elemental reactions.

## Grid and word structure

The board is not just a simple fixed Wordle grid. It is a custom grid where each cell can contain:

- a letter,
- a diacritic bonus,
- an elemental effect,
- a pattern effect that applies to surrounding cells.

Some cells can trigger effects on rows, columns, crosses, or neighbouring tiles. These effects can:

- increase the score,
- transform letters,
- repeat a bonus,
- trigger elemental reactions such as fire, water, earth, and air combinations.

This creates a more dynamic puzzle than a pure word-guessing game.

## Winning and losing

A level is won when the player reaches the score target for that level or when the correct word is guessed with enough accumulated points.

A level is lost when the player fails to reach the threshold before the available attempts are exhausted.

The game then shows a win/lose state and allows the player to continue to the next phase of progression.

## Progression and shop system

After a level, the player earns coins. Those coins can be spent in a shop to buy permanent or temporary power-ups that affect future runs.

This gives the game a roguelike progression loop:

- play a level,
- earn coins,
- buy upgrades,
- start a new level or new run,
- improve your score and your chances of success.

