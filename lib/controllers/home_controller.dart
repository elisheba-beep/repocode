import 'package:flutter/material.dart';
import 'terminal_controller.dart';
import 'extension_controller.dart';
import 'github_controller.dart';
import 'editor_controller.dart';
import 'settings_controller.dart';

class HomeController extends ChangeNotifier {
  late final TerminalController terminal;
  late final ExtensionController extensions;
  late final GithubController github;
  late final EditorController editor;
  late final SettingsController settings;

  int activeSidebarTab = 0;
  bool isSidebarOpen = true;

  HomeController() {
    terminal = TerminalController(notifyListeners);
    extensions = ExtensionController(terminal.log, notifyListeners);
    github = GithubController(terminal.log, notifyListeners);
    editor = EditorController(
      github,
      extensions,
      terminal.log,
      notifyListeners,
    );
    settings = SettingsController(notifyListeners);
  }

  List<dynamic> get currentSidebarItems {
    if (activeSidebarTab == 1) return editor.modifiedFiles.values.toList();
    if (activeSidebarTab == 2) return extensions.items;
    if (activeSidebarTab == 3) return settings.items;
    return github.sidebarItems;
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

  Future<void> runCodeSequence() async {
    terminal.log('> INITIATING RUNTIME SEQUENCE...');
    terminal.log('> Booting isolated container...');
    await Future.delayed(const Duration(milliseconds: 800));
    if (editor.currentFile != null) {
      terminal.log('> Compiling ${editor.currentFile!['name']}...');
      await Future.delayed(const Duration(seconds: 1));
      terminal.log('> ERROR: Cloud Runtime not configured for this sector.');
      terminal.log('> Execution halted. +10 XP for the attempt.');
      github.playerXp += 10;
      notifyListeners();
    } else {
      terminal.log('> No file selected for execution.');
    }
  }

  String getTerminalPrompt() {
    if (github.currentRepo == null) {
      return 'C:\\SYS_ROOT>';
    }
    final repoName = github.currentRepo!.split('/').last;
    final path = github.currentPath.isEmpty ? '/' : '/${github.currentPath}';
    return '$repoName:$path>';
  }

  Future<void> onTerminalCommand(String command) async {
    terminal.log('${getTerminalPrompt()} $command');

    final parts = command.trim().split(' ');
    final cmd = parts.first.toLowerCase();
    final args = parts.length > 1 ? parts.sublist(1) : <String>[];

    if (github.currentRepo == null && cmd.isNotEmpty) {
      terminal.log(
        '> ERROR: No repository selected. Navigate via the sidebar first.',
      );
      return;
    }

    switch (cmd) {
      case 'ls':
      case 'dir':
        final items = await github.api.getContents(
          github.currentRepo!,
          github.currentPath,
        );
        if (items.isEmpty) {
          terminal.log('(empty directory)');
          return;
        }
        final output = items
            .map((item) {
              final type = item['type'] == 'dir' ? '<DIR>' : '     ';
              return '$type    ${item['name']}';
            })
            .join('\n');
        terminal.log(output);
        break;
      case 'cd':
        if (args.isEmpty || args.first == '..') {
          github.handleBack();
        } else {
          final currentItems = await github.api.getContents(
            github.currentRepo!,
            github.currentPath,
          );
          final targetDir = currentItems.firstWhere(
            (item) => item['name'] == args.first && item['type'] == 'dir',
            orElse: () => null,
          );
          if (targetDir != null) {
            github.loadContents(github.currentRepo!, targetDir['path']);
          } else {
            terminal.log('> Directory not found: ${args.first}');
          }
        }
        break;
      case 'clear':
      case 'cls':
        terminal.logs.clear();
        terminal.log('>>> TERMINAL UPLINK ESTABLISHED');
        notifyListeners();
        break;
      case '':
        break; // Do nothing on empty command
      default:
        terminal.log(
          '> Command not found: $cmd. Supported: ls, dir, cd, clear, cls.',
        );
        break;
    }
  }

  void handleSidebarTap(dynamic item) {
    if (activeSidebarTab == 3) {
      if (item['action'] == 'minigame') settings.toggleMinigame();
      if (item['action'] == 'active_editor') settings.toggleActiveEditor();
      if (item['action'] == 'theme') {
        final options = item['options'] as List<String>;
        final currentIndex = options.indexOf(item['value']);
        final nextIndex = (currentIndex + 1) % options.length;
        settings.setTheme(options[nextIndex], editor.webViewController);
      }
      return;
    }
    if (activeSidebarTab == 2) {
      extensions.toggle(item, editor.webViewController);
      return;
    }
    if (activeSidebarTab == 1) {
      editor.openFile(item);
      return;
    }
    if (github.showingRepos) {
      github.loadContents(item['full_name']);
    } else if (item['type'] == 'dir') {
      github.loadContents(github.currentRepo!, item['path']);
    } else if (item['type'] == 'file') {
      editor.openFile(item);
    }
  }
}
