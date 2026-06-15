import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'theme/cyber_theme.dart';
import 'controllers/home_controller.dart';
import 'widgets/activity_bar.dart';
import 'widgets/gamified_sidebar.dart';
import 'widgets/editor_view.dart';
import 'widgets/terminal_panel.dart';
import 'widgets/stat_hud_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleFileClose(Map<String, dynamic> file) async {
    final path = file['path'];
    if (_controller.editor.modifiedFiles.containsKey(path)) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: cyberPanel,
          title: Text(
            'UNSAVED CHANGES',
            style: glowingText(Colors.amberAccent),
          ),
          content: const Text(
            'WARNING: You have uncommitted changes in this file. Closing it will discard your modifications. Proceed?',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Courier',
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: neonMagenta),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'DISCARD',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    await _controller.editor.closeFile(file);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cyberBg,
          body: Column(
            children: [
              StatHudHeader(
                username: _controller.github.username,
                totalCommits: _controller.github.totalCommits,
                integrityPercentage: _controller.github.integrity,
                onLogout: () async {
                  await _controller.github.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
              Expanded(
                child: Row(
                  children: [
                    ActivityBar(
                      activeTab: _controller.activeSidebarTab,
                      modifiedCount: _controller.editor.modifiedFiles.length,
                      onTabSelected: _controller.setTab,
                    ),
                    if (_controller.isSidebarOpen)
                      GamifiedSidebar(
                        activeTab: _controller.activeSidebarTab,
                        items: _controller.currentSidebarItems,
                        isShowingRepos: _controller.github.showingRepos,
                        currentRepo: _controller.github.currentRepo,
                        onBack: _controller.github.handleBack,
                        onItemTap: _controller.handleSidebarTap,
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 7,
                            child: EditorView(
                              currentFile: _controller.editor.currentFile,
                              openFiles: _controller.editor.openFiles,
                              modifiedFiles: _controller.editor.modifiedFiles,
                              playerXp: _controller.github.playerXp,
                              onWebViewCreated: (webViewController) {
                                _controller.editor.attachWebView(
                                  webViewController,
                                );
                                webViewController.addJavaScriptHandler(
                                  handlerName: 'onContentChanged',
                                  callback: (args) {
                                    if (args.isNotEmpty) {
                                      _controller.editor.onContentChanged(
                                        args[0].toString(),
                                      );
                                    }
                                  },
                                );
                              },
                              onDeploy: _controller.editor.commitChanges,
                              onContentChanged:
                                  _controller.editor.onContentChanged,
                              onFileSwitched: _controller.editor.switchFile,
                              onFileClosed: _handleFileClose,
                            ),
                          ),
                          TerminalPanel(
                            prompt: _controller.getTerminalPrompt(),
                            logs: _controller.terminal.logs.toList(),
                            onCommand: _controller.onTerminalCommand,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
