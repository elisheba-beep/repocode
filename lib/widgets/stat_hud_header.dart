import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/cyber_theme.dart';

class StatHudHeader extends StatelessWidget {
  final String username;
  final int totalCommits;
  final double integrityPercentage;
  final int playerXp;
  final VoidCallback onLogout;

  const StatHudHeader({
    super.key,
    required this.username,
    required this.totalCommits,
    required this.integrityPercentage,
    required this.playerXp,
    required this.onLogout,
  });

  String _getRankName(int level) {
    if (level <= 10) return 'Cyber-Novice';
    if (level <= 20) return 'Script Kiddie';
    if (level <= 30) return 'Console Cowboy';
    if (level <= 40) return 'Net Runner';
    if (level <= 50) return 'Byte Splicer';
    if (level <= 60) return 'Code Mercenary';
    if (level <= 70) return 'System Architect';
    if (level <= 80) return 'Glitch Weaver';
    if (level <= 90) return 'Neon Phantom';
    return 'Matrix Overlord';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cyberBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: neonMagenta, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: neonMagenta),
            const SizedBox(width: 8),
            Text(
              'SYSTEM DISCONNECT',
              style: glowingText(neonMagenta, weight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'WARNING: Severing the uplink will terminate your current session. Do you wish to return to the real world?',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Courier',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ABORT',
              style: TextStyle(color: Colors.grey, fontFamily: 'Courier'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: neonMagenta.withOpacity(0.2),
              side: const BorderSide(color: neonMagenta),
            ),
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: Text('TERMINATE UPLINK', style: glowingText(neonMagenta)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int level = math.max(1, math.min(100, math.sqrt(totalCommits).floor()));
    int nextLevel = math.min(100, level + 1);
    int commitsForNext = nextLevel * nextLevel;
    int commitsNeeded = level >= 100 ? 0 : commitsForNext - totalCommits;
    String rankName = _getRankName(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cyberPanel,
        border: const Border(bottom: BorderSide(color: neonPurple, width: 2)),
        boxShadow: [
          BoxShadow(
            color: neonPurple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar & Name
          Tooltip(
            message: 'Terminate Session',
            child: InkWell(
              onTap: () => _showLogoutDialog(context),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 40,
                height: 40,
                decoration: glowingBox(neonCyan, opacity: 0.2, isBorder: true),
                child: const Icon(Icons.power_settings_new, color: neonCyan),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  username,
                  style: glowingText(
                    neonCyan,
                    fontSize: 16,
                    weight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rank: $rankName [Lvl $level]',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                if (level < 100)
                  Text(
                    'Next Lvl: $commitsNeeded commits needed',
                    style: TextStyle(
                      color: neonMagenta.withOpacity(0.8),

                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Code Integrity Shield
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: glowingBox(neonMagenta, opacity: 0.1),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: neonMagenta, size: 18),
                const SizedBox(width: 8),
                Text(
                  'INTEGRITY: ${integrityPercentage.toStringAsFixed(1)}%',
                  style: glowingText(neonMagenta, weight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Currency / Tokens
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: glowingBox(Colors.amberAccent, opacity: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  color: Colors.amberAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$totalCommits CREDITS',
                  style: glowingText(
                    Colors.amberAccent,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // XP Token
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: glowingBox(terminalGreen, opacity: 0.1),
            child: Row(
              children: [
                const Icon(Icons.star_outline, color: terminalGreen, size: 18),
                const SizedBox(width: 8),
                Text(
                  '$playerXp XP',
                  style: glowingText(terminalGreen, weight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
