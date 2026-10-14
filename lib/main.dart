import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'engine/game_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ChangeNotifierProvider(create: (_) => GameController(), child: const LudoApp()));
}

class GameController extends ChangeNotifier {
  LudoGameState? game;
  bool soundOn = true;
  void start({bool vsComputer = false, int players = 4}) {
    game = LudoGameState(playerCount: players, computerMode: vsComputer);
    notifyListeners();
  }
  void roll() {
    final g = game;
    if (g == null || g.gameOver || g.lastRoll != null) return;
    g.rollDice();
    g.passIfNoLegalMove();
    notifyListeners();
    _runComputerTurn();
  }
  void move(int index) {
    final g = game;
    if (g == null || !g.moveToken(index)) return;
    notifyListeners();
    _runComputerTurn();
  }
  Future<void> _runComputerTurn() async {
    final g = game;
    if (g == null || g.gameOver || !g.currentPlayer.isComputer) return;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (g.lastRoll == null) g.rollDice();
    g.passIfNoLegalMove();
    final moves = g.legalTokenIndexes();
    if (moves.isNotEmpty) {
      // Medium heuristic: prefer captures, finishing, and advancing.
      moves.sort((a,b) => _score(g,b).compareTo(_score(g,a)));
      g.moveToken(moves.first);
    }
    notifyListeners();
    if (!g.gameOver && g.currentPlayer.isComputer) _runComputerTurn();
  }
  int _score(LudoGameState g, int index) {
    final t = g.currentPlayer.tokens[index];
    final roll = g.lastRoll ?? 1;
    if (t.progress + roll >= 56) return 1000;
    if (t.progress == -1) return 100;
    final next = (LudoGameState.starts[g.currentPlayer.color]! + t.progress + roll) % 52;
    if (!LudoGameState.safeCells.contains(next)) {
      for (final p in g.players.where((p) => p != g.currentPlayer)) {
        if (p.tokens.any((e) => e.progress >= 0 && e.progress <= 50 &&
          (LudoGameState.starts[p.color]! + e.progress) % 52 == next)) return 900;
      }
    }
    if (LudoGameState.safeCells.contains(next)) return 300;
    return t.progress + roll;
  }
  void reset() { game = null; notifyListeners(); }
}

class LudoApp extends StatelessWidget {
  const LudoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Ludo — Offline',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6655D9), brightness: Brightness.dark), useMaterial3: true),
    home: const MenuScreen(),
  );
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF15162E), Color(0xFF29204A), Color(0xFF101522)])),
      child: SafeArea(child: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.casino_rounded, size: 86, color: Color(0xFFB8A9FF)),
          const SizedBox(height: 14),
          const Text('LUDO', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 8)),
          const Text('ROLL • RACE • WIN', style: TextStyle(color: Colors.white60, letterSpacing: 3)),
          const SizedBox(height: 48),
          _MenuButton(label: 'PLAY VS COMPUTER', icon: Icons.smart_toy, onTap: () => context.read<GameController>().start(vsComputer: true)),
          const SizedBox(height: 14),
          _MenuButton(label: 'PASS & PLAY', icon: Icons.groups, onTap: () => context.read<GameController>().start()),
          const SizedBox(height: 14),
          _MenuButton(label: 'SETTINGS', icon: Icons.settings, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          const SizedBox(height: 24),
          const Text('Offline • No accounts • No ads', style: TextStyle(color: Colors.white54)),
        ]),
      ))),
    ),
  );
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.icon, required this.onTap});
  final String label; final IconData icon; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(width: 280, height: 54, child: FilledButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))));
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});
  Color color(PlayerColor c) => switch(c) { PlayerColor.red => const Color(0xFFFF5B67), PlayerColor.green => const Color(0xFF42D6A4), PlayerColor.yellow => const Color(0xFFFFD166), PlayerColor.blue => const Color(0xFF62A7FF) };
  @override
  Widget build(BuildContext context) {
    final g = context.watch<GameController>().game!;
    final ctl = context.read<GameController>();
    return Scaffold(appBar: AppBar(title: const Text('Ludo'), actions: [IconButton(onPressed: () => ctl.reset(), icon: const Icon(Icons.home))]),
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 8),
        Text(g.gameOver ? '${g.winner!.name.toUpperCase()} WINS!' : '${g.currentPlayer.color.name.toUpperCase()} TURN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color(g.currentPlayer.color))),
        const SizedBox(height: 8),
        Expanded(child: Padding(padding: const EdgeInsets.all(12), child: AspectRatio(aspectRatio: 1, child: CustomPaint(painter: BoardPainter(g, color), child: _TokenOverlay(game: g, color: color, onMove: ctl.move))))),
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Expanded(child: Text(g.lastRoll == null ? 'Roll the dice' : 'Dice: ${g.lastRoll}  •  Select a glowing token')),
          FilledButton.icon(onPressed: g.gameOver || g.lastRoll != null ? null : ctl.roll, icon: const Icon(Icons.casino), label: const Text('ROLL')),
        ])),
        if (g.gameOver) Padding(padding: const EdgeInsets.only(bottom: 18), child: FilledButton(onPressed: () => ctl.start(vsComputer: g.players.any((p) => p.isComputer)), child: const Text('PLAY AGAIN'))),
      ])),
    );
  }
}

class BoardPainter extends CustomPainter {
  BoardPainter(this.game, this.color);
  final LudoGameState game; final Color Function(PlayerColor) color;
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;
    final p = Paint();
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)), Paint()..color = const Color(0xFF25283D));
    final homes = [(0,0,6,6,PlayerColor.red),(9,0,6,6,PlayerColor.green),(9,9,6,6,PlayerColor.yellow),(0,9,6,6,PlayerColor.blue)];
    for(final h in homes) {
      p.color = color(h.$5).withOpacity(.24);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(h.$1*cell,h.$2*cell,h.$3*cell,h.$4*cell), const Radius.circular(12)), p);
      p.color = color(h.$5);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH((h.$1+1)*cell,(h.$2+1)*cell,4*cell,4*cell), const Radius.circular(9)), p);
      p.color = const Color(0xFFF7F7FB);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH((h.$1+1.6)*cell,(h.$2+1.6)*cell,2.8*cell,2.8*cell), const Radius.circular(8)), p);
      for(var i=0;i<4;i++) {
        p.color = color(h.$5);
        final dx=(h.$1+2.1+(i%2)*1.5)*cell, dy=(h.$2+2.1+(i~/2)*1.5)*cell;
        canvas.drawCircle(Offset(dx,dy), cell*.32, p);
      }
    }
    final track = <Point<int>>[];
    for(var x=1;x<=6;x++) track.add(Point(x,7));
    for(var y=6;y>=1;y--) track.add(Point(7,y));
    for(var y=1;y<=6;y++) track.add(Point(7,y));
    for(var x=8;x<=13;x++) track.add(Point(x,7));
    for(var y=8;y<=13;y++) track.add(Point(7,y));
    for(var x=13;x>=8;x--) track.add(Point(x,7));
    // Draw a clear 15x15 grid backdrop; token progress is displayed below as selectable chips.
    p.color = const Color(0xFF42465D);
    for(var i=0;i<=15;i++) {
      canvas.drawLine(Offset(i*cell,0),Offset(i*cell,size.height),p..strokeWidth=.35);
      canvas.drawLine(Offset(0,i*cell),Offset(size.width,i*cell),p..strokeWidth=.35);
    }
    for(final player in game.players) {
      p.color = color(player.color);
      for(var i=0;i<player.tokens.length;i++) {
        final t=player.tokens[i];
        final x=(2+(i%2)*1.5)*cell, y=(2+(i~/2)*1.5)*cell;
        final base = switch(player.color) { PlayerColor.red => Offset(x,y), PlayerColor.green => Offset(size.width-x,y), PlayerColor.yellow => Offset(size.width-x,size.height-y), PlayerColor.blue => Offset(x,size.height-y) };
        canvas.drawCircle(base,cell*.26,p);
      }
    }
  }
  @override bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}

class _TokenOverlay extends StatelessWidget {
  const _TokenOverlay({required this.game, required this.color, required this.onMove});
  final LudoGameState game; final Color Function(PlayerColor) color; final ValueChanged<int> onMove;
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.bottomCenter, child: Container(
    margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: const Color(0xDD191B2D), borderRadius: BorderRadius.circular(14)),
    child: Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
      for(var i=0;i<game.currentPlayer.tokens.length;i++)
        ChoiceChip(label: Text('Token ${i+1} • ${game.currentPlayer.tokens[i].progress == -1 ? "Base" : game.currentPlayer.tokens[i].progress == 56 ? "Home" : game.currentPlayer.tokens[i].progress}'),
          selected: game.legalTokenIndexes().contains(i), onSelected: game.legalTokenIndexes().contains(i) ? (_) => onMove(i) : null,
          selectedColor: color(game.currentPlayer.color)),
    ]),
  ));
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  @override Widget build(BuildContext context) {
    final c=context.watch<GameController>();
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: SwitchListTile(title: const Text('Sound effects'), subtitle: const Text('Sound setting placeholder for MVP'), value: c.soundOn, onChanged: (v) { c.soundOn=v; c.notifyListeners(); setState((){}); }));
  }
}
