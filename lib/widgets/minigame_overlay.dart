import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/cyber_theme.dart';
import 'minigames/memory_match.dart';
import 'minigames/tic_tac_toe.dart';
import 'minigames/tetris_game.dart';

class MinigameOverlay extends StatefulWidget {
  final VoidCallback onWin;

  const MinigameOverlay({super.key, required this.onWin});

  @override
  State<MinigameOverlay> createState() => _MinigameOverlayState();
}

class _MinigameOverlayState extends State<MinigameOverlay> {
  bool _isVisible = false;
  Timer? _triggerTimer;
  int _activeGame = 0;

  @override
  void initState() {
    super.initState();
    _startRandomTrigger();
  }

  void _startRandomTrigger() {
    _triggerTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isVisible && math.Random().nextBool()) {
        setState(() {
          _activeGame = math.Random().nextInt(3);
          _isVisible = true;
        });
      }
    });
  }

  void _handleWin() {
    setState(() => _isVisible = false);
    widget.onWin();
  }

  @override
  void dispose() {
    _triggerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    Widget activeWidget;
    if (_activeGame == 0) {
      activeWidget = MemoryMatchGame(onWin: _handleWin);
    } else if (_activeGame == 1)
      {activeWidget = TicTacToeGame(onWin: _handleWin);}
    else
      {activeWidget = TetrisGame(onWin: _handleWin);}

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 400,
          height: 500,
          padding: const EdgeInsets.all(24),
          decoration: glowingBox(neonCyan, isBorder: true),
          child: activeWidget,
        ),
      ),
    );
  }
}
