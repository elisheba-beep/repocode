import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../theme/cyber_theme.dart';

class TopNavigationBar extends StatelessWidget {
  final VoidCallback onCommandPalette;
  final VoidCallback onRunCode;

  const TopNavigationBar({
    super.key,
    required this.onCommandPalette,
    required this.onRunCode,
  });

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 40,
        color: const Color(0xFF09090E), // Very dark, matches editor bg
        child: Row(
          children: [
            // Left Side (Guild Emblem & Draggable)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.terminal, color: neonCyan, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'RepoCode',
                      style: glowingText(neonCyan, weight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // Center (The Quest Board)
            InkWell(
              onTap: onCommandPalette,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 400,
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.05),
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white54, size: 14),
                    const SizedBox(width: 8),
                    const Text(
                      'Search RepoCode or type ">" for Commands',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Ctrl+P',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Side (System Control)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: 'Execute Runtime Sequence',
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow, color: terminalGreen, size: 18),
                      onPressed: onRunCode,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Custom Window Controls
                  _WindowControlButton(
                    icon: Icons.minimize,
                    onTap: () => windowManager.minimize(),
                  ),
                  _WindowControlButton(
                    icon: Icons.crop_square,
                    onTap: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                  ),
                  _WindowControlButton(
                    icon: Icons.close,
                    hoverColor: Colors.red.withValues(alpha:0.8),
                    onTap: () => windowManager.close(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? hoverColor;

  const _WindowControlButton({required this.icon, required this.onTap, this.hoverColor});

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: 40,
          color: isHovered ? (widget.hoverColor ?? Colors.white.withValues(alpha:0.1)) : Colors.transparent,
          child: Icon(widget.icon, color: isHovered ? Colors.white : Colors.white54, size: 16),
        ),
      ),
    );
  }
}
