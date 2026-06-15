import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/github_service.dart';
import '../services/auth_service.dart';
import '../services/terminal_service.dart';

class HomeController extends ChangeNotifier {
  final GitHubService _gitHubService = GitHubService();
  final AuthService _authService = AuthService();
  final TerminalService _terminalService = TerminalService();

  int activeSidebarTab = 0;
  bool isSidebarOpen = true;
  List<dynamic> sidebarItems = [];
  Map<String, String> originalContents = {};
  Map<String, dynamic> modifiedFiles = {};
  bool showingRepos = true;
  String? currentRepo;
  String currentPath = '';
  Map<String, dynamic>? currentFile;
  int playerXp = 150;
  String username = 'Uplinking...';
  int totalCommits = 0;
  double integrity = 0.0;

  InAppWebViewController? webViewController;
  List<String> terminalLogs = [
    '>>> TERMINAL UPLINK ESTABLISHED',
    '> Accessing GitHub Databanks...',
  ];

  HomeController() {
    _loadRepos();
    _loadUserProfile();
  }

  void _log(String message) {
    if (message.isNotEmpty) {
      terminalLogs.add(message);
      if (terminalLogs.length > 100) {
        terminalLogs.removeAt(0); // Prevent memory leaks over time
      }
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _gitHubService.getUserProfile();
      username = profile['login'];
      totalCommits = await _gitHubService.getUserCommits(username);
      integrity = math.min(100.0, math.sqrt(totalCommits));
      notifyListeners();
    } catch (e) {
      _log('> ERROR: Failed to fetch profile stats.');
    }
  }

  Future<void> _loadRepos() async {
    sidebarItems = [];
    notifyListeners();
    try {
      final repos = await _gitHubService.getRepos();
      sidebarItems = repos;
      showingRepos = true;
      currentRepo = null;
      currentPath = '';
      _log('> Databanks synced: ${repos.length} repositories found.');
      notifyListeners();
    } catch (e) {
      _log('> ERROR: Failed to fetch repos - $e');
    }
  }

  Future<void> loadContents(String repoFullName, [String path = '']) async {
    sidebarItems = [];
    notifyListeners();
    try {
      final contents = await _gitHubService.getContents(repoFullName, path);
      sidebarItems = contents;
      showingRepos = false;
      currentRepo = repoFullName;
      currentPath = path;
      _log('> Directory accessed: /$path');
      notifyListeners();
    } catch (e) {
      _log('> ERROR: Directory locked - $e');
    }
  }

  Future<void> openFile(Map<String, dynamic> file) async {
    _log('> Decrypting file: ${file['name']}...');
    try {
      String content = await _gitHubService.getFileContent(file['url']);
      content = content.replaceAll('\r', '');
      currentFile = file;
      originalContents[file['path']] = content;
      notifyListeners();

      if (webViewController != null) {
        String lang = 'javascript';
        if (file['name'].endsWith('.dart')) lang = 'dart';
        if (file['name'].endsWith('.py')) lang = 'python';
        if (file['name'].endsWith('.html')) lang = 'html';

        final escapedContent = content
            .replaceAll(r'\', r'\\')
            .replaceAll("'", r"\'")
            .replaceAll('\n', r'\n');
        await webViewController!.evaluateJavascript(
          source: "setContent('$escapedContent', '$lang')",
        );
        _log('> File decrypted successfully.');
      }
    } catch (e) {
      _log('> ERROR: File corruption detected - $e');
    }
  }

  void onContentChanged(String newContent) {
    if (currentFile == null) return;
    final path = currentFile!['path'];
    final original = originalContents[path];

    final wasModified = modifiedFiles.containsKey(path);
    final isModified = original != null && original != newContent;

    // Only notify listeners if the state actually toggled to avoid massive rebuilds
    if (isModified != wasModified) {
      if (isModified) {
        modifiedFiles[path] = currentFile!;
      } else {
        modifiedFiles.remove(path);
      }
      notifyListeners();
    }
  }

  Future<void> commitChanges(String _, String message) async {
    if (currentFile == null || currentRepo == null) return;
    _log('> Commencing DEPLOY sequence...');
    try {
      String newContent = '';
      if (webViewController != null) {
        final result = await webViewController!.evaluateJavascript(
          source: "getContent()",
        );
        newContent = result?.toString() ?? '';
      }

      final newSha = await _gitHubService.commitFile(
        repoFullName: currentRepo!,
        path: currentFile!['path'],
        content: newContent,
        message: message,
        sha: currentFile!['sha'],
      );

      currentFile!['sha'] = newSha;
      originalContents[currentFile!['path']] = newContent;
      playerXp += 50;
      totalCommits += 1;
      modifiedFiles.remove(currentFile!['path']);
      integrity = math.min(100.0, math.sqrt(totalCommits));
      _log('> QUEST COMPLETE: Code deployed successfully (+50 XP)');
      notifyListeners();

      loadContents(currentRepo!, currentPath);
    } catch (e) {
      _log('> ERROR: Deploy sequence failed - $e');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> handleTerminalCommand(String command) async {
    // Display dynamic directory instead of hardcoded SYS_ROOT
    _log('${_terminalService.currentDirectory}> $command');
    
    final output = await _terminalService.executeCommand(command);
    _log(output);
  }

  List<dynamic> get currentSidebarItems {
    if (activeSidebarTab == 1) return modifiedFiles.values.toList();
    if (activeSidebarTab == 2)
      return ['GitHub Copilot', 'Neon Syntax', 'Prettier', 'Code-Bot Analyzer'];
    return sidebarItems;
  }

  void setTab(int index) {
    if (activeSidebarTab == index) {
      isSidebarOpen = !isSidebarOpen;
    } else {
      isSidebarOpen = true;
      activeSidebarTab = index;
    }
    notifyListeners();
  }

  void handleBack() {
    if (currentPath.isEmpty) {
      _loadRepos();
    } else {
      final parts = currentPath.split('/');
      parts.removeLast();
      loadContents(currentRepo!, parts.join('/'));
    }
  }

  void handleSidebarTap(dynamic item) {
    if (activeSidebarTab == 2) return;
    if (activeSidebarTab == 1) {
      openFile(item);
      return;
    }
    if (showingRepos) {
      loadContents(item['full_name']);
    } else if (item['type'] == 'dir') {
      loadContents(currentRepo!, item['path']);
    } else if (item['type'] == 'file') {
      openFile(item);
    }
  }
}
