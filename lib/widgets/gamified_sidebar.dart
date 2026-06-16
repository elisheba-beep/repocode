import 'package:flutter/material.dart';
import '../../theme/cyber_theme.dart';

class GamifiedSidebar extends StatelessWidget {
  final int activeTab;
  final List<dynamic> items;
  final bool isShowingRepos;
  final String? currentRepo;
  final Function(dynamic) onItemTap;
  final VoidCallback onBack;

  const GamifiedSidebar({
    super.key,
    required this.activeTab,
    required this.items,
    required this.isShowingRepos,
    required this.currentRepo,
    required this.onItemTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'DATABANKS (REPOS)';
    if (activeTab == 0 && !isShowingRepos && currentRepo != null) {
      title = currentRepo!.split('/').last.toUpperCase();
    } else if (activeTab == 1) {
      title = 'SOURCE CONTROL';
    } else if (activeTab == 2) {
      title = 'EXTENSIONS';
    } else if (activeTab == 3) {
      title = 'SETTINGS';
    }

    return Container(
      width: 250,
      color: cyberPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black26,
            child: Row(
              children: [
                if (activeTab == 0 && !isShowingRepos)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: neonCyan,
                      size: 16,
                    ),
                    onPressed: onBack,
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: glowingText(neonCyan, weight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty && activeTab == 1
                ? SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _PulsingIcon(),
                        const SizedBox(height: 16),
                        Text(
                          'NO PENDING CHANGES',
                          style: glowingText(
                            Colors.white30,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (activeTab == 1) return _buildModifiedNode(item);
                      if (activeTab == 2) return _buildExtensionNode(item);
                      if (activeTab == 3) return _buildSettingNode(item);
                      return _buildNode(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(dynamic item) {
    final name = item['name'];
    final isFolder = isShowingRepos || item['type'] == 'dir';
    final icon = isShowingRepos
        ? Icons.dns_outlined
        : (isFolder ? Icons.folder_rounded : Icons.insert_drive_file_outlined);

    return InkWell(
      onTap: () => onItemTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isFolder ? neonPurple : Colors.white60, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModifiedNode(dynamic item) {
    return InkWell(
      onTap: () => onItemTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.edit_document,
              color: Colors.amberAccent,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item['name'],
                style: glowingText(Colors.amberAccent),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.circle, color: Colors.amberAccent, size: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionNode(dynamic item) {
    final bool isInstalled = item['installed'] ?? false;
    final String name = item['name'];
    final String desc = item['description'] ?? '';

    return InkWell(
      onTap: () => onItemTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.extension,
              color: isInstalled ? terminalGreen : Colors.white30,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isInstalled ? Colors.white70 : Colors.white30,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (desc.isNotEmpty)
                    Text(
                      desc,
                      style: TextStyle(
                        color: isInstalled ? Colors.white54 : Colors.white24,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              isInstalled ? Icons.toggle_on : Icons.toggle_off,
              color: isInstalled ? terminalGreen : Colors.white30,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingNode(dynamic item) {
    final type = item['type'];
    final name = item['name'];
    final value = item['value'];

    return InkWell(
      onTap: () => onItemTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Icon(
              type == 'toggle' ? Icons.gamepad : Icons.palette,
              color: Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (type == 'toggle')
              Icon(
                value ? Icons.check_box : Icons.check_box_outline_blank,
                color: value ? terminalGreen : Colors.white30,
                size: 20,
              )
            else if (type == 'select')
              Text(
                value,
                style: const TextStyle(color: neonCyan, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon();

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: const Icon(
          Icons.check_circle_outline,
          color: Colors.white24,
          size: 48,
        ),
      ),
    );
  }
}
