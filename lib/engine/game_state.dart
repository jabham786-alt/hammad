import 'dart:math';

enum PlayerColor { red, green, yellow, blue }

class LudoToken {
  int progress = -1; // -1 base, 0..50 track, 51..55 home lane, 56 finished
  LudoToken();
  LudoToken.at(this.progress);
  bool get finished => progress == 56;
}

class LudoPlayer {
  LudoPlayer(this.color, {this.isComputer = false})
      : tokens = List.generate(4, (_) => LudoToken());
  final PlayerColor color;
  final bool isComputer;
  final List<LudoToken> tokens;
  int get finishedCount => tokens.where((t) => t.finished).length;
}

class LudoGameState {
  LudoGameState({Random? random, int playerCount = 4, bool computerMode = false})
      : _random = random ?? Random(),
        players = List.generate(playerCount.clamp(2, 4).toInt(), (i) => LudoPlayer(
          PlayerColor.values[i],
          isComputer: computerMode && i > 0,
        ));
  final Random _random;
  final List<LudoPlayer> players;
  int currentPlayerIndex = 0;
  int? lastRoll;
  int consecutiveSixes = 0;
  bool gameOver = false;
  PlayerColor? winner;

  LudoPlayer get currentPlayer => players[currentPlayerIndex];
  static const starts = <PlayerColor, int>{
    PlayerColor.red: 0, PlayerColor.green: 13,
    PlayerColor.yellow: 26, PlayerColor.blue: 39,
  };
  static const safeCells = <int>{0, 8, 13, 21, 26, 34, 39, 47};

  int rollDice() {
    if (gameOver) return 0;
    lastRoll = _random.nextInt(6) + 1;
    consecutiveSixes = lastRoll == 6 ? consecutiveSixes + 1 : 0;
    if (consecutiveSixes >= 3) {
      consecutiveSixes = 0;
      lastRoll = null;
      _nextPlayer();
      return 6;
    }
    return lastRoll!;
  }

  List<int> legalTokenIndexes() {
    final roll = lastRoll;
    if (gameOver || roll == null) return [];
    return [for (var i = 0; i < currentPlayer.tokens.length; i++)
      if (_isLegal(currentPlayer.tokens[i], roll)) i];
  }

  bool _isLegal(LudoToken token, int roll) =>
      token.progress == -1 ? roll == 6 : token.progress + roll <= 56;

  bool moveToken(int tokenIndex) {
    if (gameOver || lastRoll == null || !legalTokenIndexes().contains(tokenIndex)) return false;
    final roll = lastRoll!;
    final token = currentPlayer.tokens[tokenIndex];
    final wasFinished = token.finished;
    token.progress = token.progress == -1 ? 0 : token.progress + roll;
    var captured = false;
    if (token.progress <= 50) {
      final cell = (starts[currentPlayer.color]! + token.progress) % 52;
      if (!safeCells.contains(cell)) {
        for (final opponent in players.where((p) => p != currentPlayer)) {
          final occupants = opponent.tokens.where((t) =>
            t.progress >= 0 && t.progress <= 50 &&
            (starts[opponent.color]! + t.progress) % 52 == cell).toList();
          if (occupants.isNotEmpty) {
            for (final enemy in occupants) { enemy.progress = -1; }
            captured = true;
          }
        }
      }
    }
    final finishedNow = !wasFinished && token.finished;
    if (currentPlayer.finishedCount == 4) {
      gameOver = true;
      winner = currentPlayer.color;
    }
    final extraTurn = roll == 6 || captured || finishedNow;
    lastRoll = null;
    if (!extraTurn && !gameOver) _nextPlayer();
    return true;
  }

  void passIfNoLegalMove() {
    if (lastRoll != null && legalTokenIndexes().isEmpty) {
      final roll = lastRoll!;
      lastRoll = null;
      if (!gameOver) _nextPlayer();
    }
  }

  void _nextPlayer() => currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
}
