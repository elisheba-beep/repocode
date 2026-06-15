import 'package:flutter/material.dart';
import '../../theme/cyber_theme.dart';

class TerminalPanel extends StatelessWidget {
  final List<String> logs;

  const TerminalPanel({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: terminalGreen, width: 2)),
      ),
      child: Stack(
        children: [
          // Retro Scanline Overlay
          CustomPaint(painter: CRTScanlinePainter(), child: Container()),

          // Terminal Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          logs[index],
                          style: TextStyle(
                            color: terminalGreen.withOpacity(0.8),
                            fontFamily: 'Courier',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Text('C:\\SYS_ROOT> ', style: glowingText(terminalGreen)),
                    Container(
                      width: 10,
                      height: 16,
                      color: terminalGreen.withOpacity(0.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CRTScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.height; i += 4)
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
