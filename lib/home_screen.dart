import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'services/github_service.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'theme/cyber_theme.dart';
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
  final GitHubService _gitHubService = GitHubService();
  final AuthService _authService = AuthService();

  int _activeSidebarTab = 0;
  bool _isSidebarOpen = true;
  List<dynamic> _sidebarItems = [];
  Map<String, String> _originalContents = {};
  Map<String, dynamic> _modifiedFiles = {};
  bool _showingRepos = true;
  String? _currentRepo;
  String _currentPath = '';
  Map<String, dynamic>? _currentFile;
  int _playerXp = 150;
  String _username = 'Uplinking...';
  int _totalCommits = 0;
  double _integrity = 0.0;

  InAppWebViewController? _webViewController;
  List<String> _terminalLogs = [
    '>>> TERMINAL UPLINK ESTABLISHED',
    '> Accessing GitHub Databanks...',
  ];

  @override
  void initState() {
    super.initState();
    _loadRepos();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _gitHubService.getUserProfile();
      final username = profile['login'];
      final commits = await _gitHubService.getUserCommits(username);
      if (mounted) {
        setState(() {
          _username = username;
          _totalCommits = commits;

          // Gamified calculation: Based on your rank/progress exactly like the rank level.
          _integrity = math.min(100.0, math.sqrt(commits));
        });
      }
    } catch (e) {
      _log('> ERROR: Failed to fetch profile stats.');
    }
  }

  void _log(String message) {
    setState(() => _terminalLogs.add(message));
  }

  Future<void> _loadRepos() async {
    setState(() => _sidebarItems = []);
    try {
      final repos = await _gitHubService.getRepos();
      setState(() {
        _sidebarItems = repos;
        _showingRepos = true;
        _currentRepo = null;
        _currentPath = '';
      });
      _log('> Databanks synced: ${repos.length} repositories found.');
    } catch (e) {
      _log('> ERROR: Failed to fetch repos - $e');
    }
  }

  Future<void> _loadContents(String repoFullName, [String path = '']) async {
    setState(() => _sidebarItems = []);
    try {
      final contents = await _gitHubService.getContents(repoFullName, path);
      setState(() {
        _sidebarItems = contents;
        _showingRepos = false;
        _currentRepo = repoFullName;
        _currentPath = path;
      });
      _log('> Directory accessed: /$path');
    } catch (e) {
      _log('> ERROR: Directory locked - $e');
    }
  }

  Future<void> _openFile(Map<String, dynamic> file) async {
    _log('> Decrypting file: ${file['name']}...');
    try {
      String content = await _gitHubService.getFileContent(file['url']);
      content = content.replaceAll('\r', ''); // Normalize line endings
      setState(() {
        _currentFile = file;
        _originalContents[file['path']] = content;
      });

      if (_webViewController != null) {
        // Determine language for syntax highlighting
        String lang = 'javascript';
        if (file['name'].endsWith('.dart')) lang = 'dart';
        if (file['name'].endsWith('.py')) lang = 'python';
        if (file['name'].endsWith('.html')) lang = 'html';

        // Inject into Monaco
        final escapedContent = content
            .replaceAll(r'\', r'\\')
            .replaceAll("'", r"\'")
            .replaceAll('\n', r'\n');
        await _webViewController!.evaluateJavascript(
          source: "setContent('$escapedContent', '$lang')",
        );
        _log('> File decrypted successfully.');
      }
    } catch (e) {
      _log('> ERROR: File corruption detected - $e');
    }
  }

  void _onContentChanged(String newContent) {
    if (_currentFile == null) return;
    final path = _currentFile!['path'];
    final original = _originalContents[path];

    if (original != null && original != newContent) {
      setState(() {
        _modifiedFiles[path] = _currentFile!; // store the modified file node
      });
    } else {
      setState(() {
        _modifiedFiles.remove(path); // Content restored to original
      });
    }
  }

  Future<void> _commitChanges(String _, String message) async {
    if (_currentFile == null || _currentRepo == null) return;
    _log('> Commencing DEPLOY sequence...');
    try {
      String newContent = '';
      if (_webViewController != null) {
        final result = await _webViewController!.evaluateJavascript(
          source: "getContent()",
        );
        newContent = result?.toString() ?? '';
      }

      final newSha = await _gitHubService.commitFile(
        repoFullName: _currentRepo!,
        path: _currentFile!['path'],
        content: newContent,
        message: message,
        sha: _currentFile!['sha'],
      );
      setState(() {
        _currentFile!['sha'] = newSha;
        _originalContents[_currentFile!['path']] = newContent; // Update the baseline!
        _playerXp += 50;
        _totalCommits += 1;
        _modifiedFiles.remove(_currentFile!['path']);
        _integrity = math.min(100.0, math.sqrt(_totalCommits));
      });
      _log('> QUEST COMPLETE: Code deployed successfully (+50 XP)');

      // Reload contents to get the updated SHA
      _loadContents(_currentRepo!, _currentPath);
    } catch (e) {
      _log('> ERROR: Deploy sequence failed - $e');
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  List<dynamic> get _currentSidebarItems {
    if (_activeSidebarTab == 1) {
      return _modifiedFiles.values.toList();
    } else if (_activeSidebarTab == 2) {
      return [
        'GitHub Copilot',
        'Neon Syntax',
        'Prettier',
        'Code-Bot Analyzer',
      ]; // Dummy Gamified Extensions
    }
    return _sidebarItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cyberBg,
      body: Column(
        children: [
          // Top Gamified HUD
          StatHudHeader(
            username: _username,
            totalCommits: _totalCommits,
            integrityPercentage: _integrity,
            onLogout: _logout,
          ),

          // Main Layout
          Expanded(
            child: Row(
              children: [
                ActivityBar(
                  activeTab: _activeSidebarTab,
                  modifiedCount: _modifiedFiles.length,
                  onTabSelected: (index) {
                    setState(() {
                      if (_activeSidebarTab == index) {
                        _isSidebarOpen = !_isSidebarOpen;
                      } else {
                        _isSidebarOpen = true;
                        _activeSidebarTab = index;
                      }
                    });
                  },
                ),
                if (_isSidebarOpen)
                  GamifiedSidebar(
                    activeTab: _activeSidebarTab,
                    items: _currentSidebarItems,
                    isShowingRepos: _showingRepos,
                    currentRepo: _currentRepo,
                    onBack: () {
                      if (_currentPath.isEmpty) {
                        _loadRepos();
                      } else {
                        final parts = _currentPath.split('/');
                        parts.removeLast();
                        _loadContents(_currentRepo!, parts.join('/'));
                      }
                    },
                    onItemTap: (item) {
                      if (_activeSidebarTab == 2)
                        return; // Extensions are not clickable
                      if (_activeSidebarTab == 1) {
                        _openFile(item);
                        return;
                      }
                      if (_showingRepos) {
                        _loadContents(item['full_name']);
                      } else if (item['type'] == 'dir') {
                        _loadContents(_currentRepo!, item['path']);
                      } else if (item['type'] == 'file') {
                        _openFile(item);
                      }
                    },
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 7,
                        child: EditorView(
                          currentFile: _currentFile,
                          playerXp: _playerXp,
                          onWebViewCreated: (controller) {
                            _webViewController = controller;
                            controller.addJavaScriptHandler(
                              handlerName: 'onContentChanged',
                              callback: (args) {
                                if (args.isNotEmpty) {
                                  _onContentChanged(args[0].toString());
                                }
                              },
                            );
                          },
                          onDeploy: _commitChanges,
                          onContentChanged: _onContentChanged,
                        ),
                      ),
                      TerminalPanel(logs: _terminalLogs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
