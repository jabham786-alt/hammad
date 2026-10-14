import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ludo/engine/game_state.dart';

void main() {
  test('game starts with four players and four tokens each', () {
    final game = LudoGameState(random: Random(1));
    expect(game.players.length, 4);
    expect(game.players.first.tokens.length, 4);
  });
  test('tokens start in base', () {
    final game = LudoGameState(random: Random(2));
    expect(game.currentPlayer.tokens.every((t) => t.progress == -1), isTrue);
  });
  test('safe cells are defined', () {
    expect(LudoGameState.safeCells, containsAll([0,8,13,21,26,34,39,47]));
  });
  test('players have unique start cells', () {
    expect(LudoGameState.starts.values.toSet().length, 4);
  });
  test('a token cannot leave base without a six', () {
    final game = LudoGameState(random: Random(7));
    game.lastRoll = 3;
    expect(game.legalTokenIndexes(), isEmpty);
  });
  test('exact finish limit is 56', () {
    final game = LudoGameState(random: Random(3));
    game.currentPlayer.tokens[0].progress = 54;
    game.lastRoll = 2;
    expect(game.legalTokenIndexes(), contains(0));
    game.lastRoll = 3;
    expect(game.legalTokenIndexes(), isNot(contains(0)));
  });
}
