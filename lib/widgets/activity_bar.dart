import 'package:flutter/material.dart';
import '../../theme/cyber_theme.dart';

class ActivityBar extends StatelessWidget {
  final int activeTab;
  final Function(int) onTabSelected;
  final int modifiedCount;

  const ActivityBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    this.modifiedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      color: cyberBg,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildActivityIcon(Icons.folder_outlined, neonCyan, 'Explorer', 0),
          _buildActivityIcon(
            Icons.commit_outlined,
            neonPurple,
            'Source Control',
            1,
            badgeCount: modifiedCount,
          ),
          _buildActivityIcon(
            Icons.extension,
            Colors.amberAccent,
            'Extensions',
            2,
          ),
          const Spacer(),
          _buildActivityIcon(
            Icons.settings_outlined,
            Colors.grey,
            'Settings',
            3,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActivityIcon(
    IconData icon,
    Color color,
    String tooltip,
    int index, {
    int badgeCount = 0,
  }) {
    final isActive = activeTab == index;
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: isActive
                ? Border(left: BorderSide(color: color, width: 3))
                : null,
            color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isActive ? color : color.withOpacity(0.5),
                size: 24,
                shadows: isActive
                    ? [Shadow(color: color.withOpacity(0.8), blurRadius: 10)]
                    : [],
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: neonMagenta,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
