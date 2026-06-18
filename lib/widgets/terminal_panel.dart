import 'package:flutter/material.dart';
import '../../theme/cyber_theme.dart';

class TerminalPanel extends StatefulWidget {
  final List<String> logs;
  final Function(String)? onCommand;
  final String prompt;

  const TerminalPanel({
    super.key,
    required this.logs,
    this.onCommand,
    this.prompt = 'C:\\SYS_ROOT> ',
  });

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
                    reverse: true, // Flips the list upside down!
                    controller: _scrollController,
                    itemCount: widget.logs.length,
                    itemBuilder: (context, index) {
                      // Because the list is upside down, we must read the logs backwards
                      final logIndex = widget.logs.length - 1 - index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: SelectableText(
                          widget.logs[logIndex],
                          style: TextStyle(
                            color: terminalGreen.withValues(alpha: 0.8),
                            fontFamily: 'Courier',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Text(widget.prompt, style: glowingText(terminalGreen)),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: TextStyle(
                          color: terminalGreen.withValues(alpha: 0.8),
                          fontFamily: 'Courier',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        cursorColor: terminalGreen,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty &&
                              widget.onCommand != null) {
                            widget.onCommand!(value);
                          }
                          _controller.clear();
                          _focusNode.requestFocus();
                        },
                      ),
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
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
