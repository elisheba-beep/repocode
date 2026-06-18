import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../theme/cyber_theme.dart';

class TicTacToeGame extends StatefulWidget {
  final VoidCallback onWin;
  const TicTacToeGame({super.key, required this.onWin});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = List.filled(9, '');
  bool _playerTurn = true;

  void _initGame() {
    setState(() {
      _board = List.filled(9, '');
      _playerTurn = true;
    });
  }

  void _tap(int i) {
    if (_board[i].isNotEmpty || !_playerTurn) return;
    setState(() {
      _board[i] = 'X';
      _playerTurn = false;
    });

    if (_checkWin('X')) {
      Future.delayed(const Duration(milliseconds: 500), widget.onWin);
      return;
    }
    if (!_board.contains('')) {
      Future.delayed(const Duration(milliseconds: 500), _initGame); // Draw
      return;
    }

    // AI Turn
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      List<int> empty = [];
      for (int j = 0; j < 9; j++) {
        if (_board[j] == '') empty.add(j);
      }

      if (empty.isNotEmpty) {
        int move = empty[math.Random().nextInt(empty.length)];
        setState(() {
          _board[move] = 'O';
          _playerTurn = true;
        });
        if (_checkWin('O')) {
          Future.delayed(
            const Duration(milliseconds: 500),
            _initGame,
          ); // AI Win
        }
      }
    });
  }

  bool _checkWin(String p) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var l in lines) {
      if (_board[l[0]] == p && _board[l[1]] == p && _board[l[2]] == p) {
        return true;
    }
      }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SYSTEM BREACH: OVERRIDE AI',
          style: glowingText(
            neonMagenta,
            weight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Match 3 nodes in a row to win!',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _tap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: cyberPanel,
                  border: Border.all(color: neonCyan),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _board[index],
                    style: glowingText(
                      _board[index] == 'X' ? terminalGreen : neonMagenta,
                      fontSize: 36,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
