import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../theme/cyber_theme.dart';

class TetrisGame extends StatefulWidget {
  final VoidCallback onWin;
  const TetrisGame({super.key, required this.onWin});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const int tCols = 10;
  static const int tRows = 16;
  List<Color?> _board = List.filled(tCols * tRows, null);
  List<math.Point<int>> _piece = [];
  Color _color = neonCyan;
  int _px = 0;
  int _py = 0;
  Timer? _timer;

  final List<List<math.Point<int>>> _shapes = [
    [
      const math.Point(0, 0),
      const math.Point(1, 0),
      const math.Point(0, 1),
      const math.Point(1, 1),
    ], // O
    [
      const math.Point(0, 1),
      const math.Point(1, 1),
      const math.Point(2, 1),
      const math.Point(3, 1),
    ], // I
    [
      const math.Point(1, 0),
      const math.Point(1, 1),
      const math.Point(1, 2),
      const math.Point(2, 2),
    ], // L
    [
      const math.Point(1, 0),
      const math.Point(0, 1),
      const math.Point(1, 1),
      const math.Point(2, 1),
    ], // T
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _board = List.filled(tCols * tRows, null);
    _spawn();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  void _spawn() {
    _piece = List.from(_shapes[math.Random().nextInt(_shapes.length)]);
    _color = [
      neonCyan,
      neonMagenta,
      terminalGreen,
      Colors.amberAccent,
    ][math.Random().nextInt(4)];
    _px = 3;
    _py = 0;
    if (_checkCollision(_px, _py, _piece)) {
      _initGame(); // Game over, auto-restart
    }
  }

  bool _checkCollision(int nx, int ny, List<math.Point<int>> p) {
    for (var point in p) {
      int x = nx + point.x;
      int y = ny + point.y;
      if (x < 0 || x >= tCols || y >= tRows) return true;
      if (y >= 0 && _board[y * tCols + x] != null) return true;
    }
    return false;
  }

  void _tick() {
    if (_checkCollision(_px, _py + 1, _piece)) {
      for (var p in _piece) {
        int x = _px + p.x;
        int y = _py + p.y;
        if (y >= 0) _board[y * tCols + x] = _color;
      }
      _checkLines();
      _spawn();
    } else {
      setState(() => _py++);
    }
  }

  void _checkLines() {
    for (int y = 0; y < tRows; y++) {
      bool full = true;
      for (int x = 0; x < tCols; x++) {
        if (_board[y * tCols + x] == null) full = false;
      }
      if (full) {
        _timer?.cancel();
        widget.onWin();
        return;
      }
    }
  }

  void _move(int dx) {
    if (!_checkCollision(_px + dx, _py, _piece)) setState(() => _px += dx);
  }

  void _rotate() {
    List<math.Point<int>> newP = _piece
        .map((p) => math.Point(-p.y, p.x))
        .toList();
    int minX = newP.map((p) => p.x).reduce(math.min);
    int minY = newP.map((p) => p.y).reduce(math.min);
    newP = newP.map((p) => math.Point(p.x - minX, p.y - minY)).toList();
    if (!_checkCollision(_px, _py, newP)) setState(() => _piece = newP);
  }

  void _drop() {
    while (!_checkCollision(_px, _py + 1, _piece)) {
      _py++;
    }
    _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'MEMORY FRAGMENTATION',
          style: glowingText(
            neonMagenta,
            weight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Clear 1 line of blocks to repair memory!',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            color: Colors.black,
          ),
          child: Stack(
            children: [
              for (int y = 0; y < tRows; y++)
                for (int x = 0; x < tCols; x++)
                  if (_board[y * tCols + x] != null)
                    Positioned(
                      left: x * 20.0,
                      top: y * 20.0,
                      child: Container(
                        width: 20,
                        height: 20,
                        color: _board[y * tCols + x],
                        margin: const EdgeInsets.all(1),
                      ),
                    ),
              for (var p in _piece)
                Positioned(
                  left: (_px + p.x) * 20.0,
                  top: (_py + p.y) * 20.0,
                  child: Container(
                    width: 20,
                    height: 20,
                    color: _color,
                    margin: const EdgeInsets.all(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, color: neonCyan),
              onPressed: () => _move(-1),
            ),
            IconButton(
              icon: const Icon(Icons.rotate_right, color: neonCyan),
              onPressed: _rotate,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, color: neonCyan),
              onPressed: () => _move(1),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down, color: neonCyan),
              onPressed: _drop,
            ),
          ],
        ),
      ],
    );
  }
}
