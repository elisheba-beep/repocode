import 'package:flutter/material.dart';

// --- Theme Constants ---
const Color cyberBg = Color(0xFF09090E);
const Color cyberPanel = Color(0xFF12121A);
const Color neonCyan = Color(0xFF00F0FF);
const Color neonMagenta = Color(0xFFFF003C);
const Color neonPurple = Color(0xFFB026FF);
const Color terminalGreen = Color(0xFF39FF14);

TextStyle glowingText(
  Color color, {
  double fontSize = 14,
  FontWeight weight = FontWeight.normal,
}) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: weight,
    fontFamily: 'Courier',
    shadows: [
      Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8),
      Shadow(color: color.withValues(alpha: 0.4), blurRadius: 16),
    ],
  );
}

BoxDecoration glowingBox(
  Color color, {
  double opacity = 0.1,
  bool isBorder = true,
}) {
  return BoxDecoration(
    color: isBorder ? cyberPanel : color.withValues(alpha: opacity),
    border: isBorder ? Border.all(color: color, width: 1.5) : null,
    borderRadius: BorderRadius.circular(4),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  );
}
