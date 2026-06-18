import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ActiveEditorOverlay extends StatefulWidget {
  final VoidCallback onCoinTap;

  const ActiveEditorOverlay({super.key, required this.onCoinTap});

  @override
  State<ActiveEditorOverlay> createState() => _ActiveEditorOverlayState();
}

class _ActiveEditorOverlayState extends State<ActiveEditorOverlay> {
  final math.Random _random = math.Random();
  Timer? _spawnTimer;
  final List<CoinData> _coins = [];

  @override
  void initState() {
    super.initState();
    _spawnTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_random.nextBool()) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        setState(() {
          _coins.add(
            CoinData(id: id, x: _random.nextDouble(), y: _random.nextDouble()),
          );
        });
        // Auto-remove coin after 3 seconds if not collected
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _coins.removeWhere((c) => c.id == id));
        });
      }
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _collectCoin(String id) {
    setState(() => _coins.removeWhere((c) => c.id == id));
    widget.onCoinTap();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _coins.map((coin) {
            return Positioned(
              left: coin.x * (constraints.maxWidth - 40),
              top: coin.y * (constraints.maxHeight - 40),
              child: GestureDetector(
                onTap: () => _collectCoin(coin.id),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.amberAccent,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.amber, blurRadius: 10)],
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class CoinData {
  final String id;
  final double x;
  final double y;
  CoinData({required this.id, required this.x, required this.y});
}
