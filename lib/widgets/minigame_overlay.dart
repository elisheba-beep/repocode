import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/cyber_theme.dart';

class MinigameOverlay extends StatefulWidget {
  final VoidCallback onWin;

  const MinigameOverlay({super.key, required this.onWin});

  @override
  State<MinigameOverlay> createState() => _MinigameOverlayState();
}

class _MinigameOverlayState extends State<MinigameOverlay> {
  bool _isVisible = false;
  Timer? _triggerTimer;

  // Cyber-Match Game State
  List<IconData> _grid = [];
  List<bool> _matched = [];
  List<bool> _flipped = [];
  int? _firstSelectedIndex;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startRandomTrigger();
  }

  void _initGame() {
    List<IconData> baseIcons = [
      Icons.bug_report,
      Icons.memory,
      Icons.terminal,
      Icons.code,
      Icons.developer_board,
      Icons.security,
      Icons.wifi,
      Icons.data_usage,
    ];
    _grid = [...baseIcons, ...baseIcons];
    _grid.shuffle(math.Random());
    _matched = List.filled(16, false);
    _flipped = List.filled(16, false);
    _firstSelectedIndex = null;
    _isProcessing = false;
  }

  void _startRandomTrigger() {
    _triggerTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isVisible && math.Random().nextBool()) {
        _initGame();
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  void _onCardTap(int index) async {
    if (_isProcessing || _matched[index] || _flipped[index]) return;

    setState(() => _flipped[index] = true);

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _isProcessing = true;
      int first = _firstSelectedIndex!;
      int second = index;

      if (_grid[first] == _grid[second]) {
        _matched[first] = true;
        _matched[second] = true;
        _isProcessing = false;

        if (_matched.every((m) => m)) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _isVisible = false);
              widget.onWin();
            }
          });
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          setState(() {
            _flipped[first] = false;
            _flipped[second] = false;
          });
        }
        _isProcessing = false;
      }
      _firstSelectedIndex = null;
    }
  }

  @override
  void dispose() {
    _triggerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 400,
          height: 480,
          padding: const EdgeInsets.all(24),
          decoration: glowingBox(neonCyan, isBorder: true),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SYSTEM INTRUSION DETECTED',
                style: glowingText(
                  neonMagenta,
                  weight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Text(
                'Decrypt the nodes to clear the event!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  bool isRevealed = _flipped[index] || _matched[index];
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isRevealed ? cyberPanel : Colors.black54,
                        border: Border.all(
                          color: _matched[index]
                              ? terminalGreen
                              : (isRevealed ? neonCyan : neonPurple),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isRevealed
                          ? Icon(
                              _grid[index],
                              color: _matched[index] ? terminalGreen : neonCyan,
                            )
                          : const Icon(
                              Icons.help_outline,
                              color: Colors.white24,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
