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
                username: _controller.username,
                totalCommits: _controller.totalCommits,
                integrityPercentage: _controller.integrity,
                onLogout: () async {
                  await _controller.logout();
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
                      modifiedCount: _controller.modifiedFiles.length,
                      onTabSelected: _controller.setTab,
                    ),
                    if (_controller.isSidebarOpen)
                      GamifiedSidebar(
                        activeTab: _controller.activeSidebarTab,
                        items: _controller.currentSidebarItems,
                        isShowingRepos: _controller.showingRepos,
                        currentRepo: _controller.currentRepo,
                        onBack: _controller.handleBack,
                        onItemTap: _controller.handleSidebarTap,
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 7,
                            child: EditorView(
                              currentFile: _controller.currentFile,
                              openFiles: _controller.openFiles,
                              playerXp: _controller.playerXp,
                              onWebViewCreated: (webViewController) {
                                _controller.webViewController =
                                    webViewController;
                                webViewController.addJavaScriptHandler(
                                  handlerName: 'onContentChanged',
                                  callback: (args) {
                                    if (args.isNotEmpty) {
                                      _controller.onContentChanged(
                                        args[0].toString(),
                                      );
                                    }
                                  },
                                );
                              },
                              onDeploy: _controller.commitChanges,
                              onContentChanged: _controller.onContentChanged,
                              onFileSwitched: _controller.switchFile,
                              onFileClosed: _controller.closeFile,
                            ),
                          ),
                          TerminalPanel(
                            logs: _controller.terminalLogs.toList(),
                            onCommand: _controller.handleTerminalCommand,
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
