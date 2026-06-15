import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'github_controller.dart';
import 'extension_controller.dart';

class EditorController {
  final GithubController github;
  final ExtensionController extensions;
  final Function(String) log;
  final Function notify;

  Map<String, String> originalContents = {};
  Map<String, String> workingContents = {};
  List<Map<String, dynamic>> openFiles = [];
  Map<String, dynamic> modifiedFiles = {};
  Map<String, dynamic>? currentFile;

  InAppWebViewController? webViewController;

  EditorController(this.github, this.extensions, this.log, this.notify);

  void attachWebView(InAppWebViewController controller) {
    webViewController = controller;
    extensions.applyTheme(controller);
    extensions.applyLinter(controller);
  }

  Future<void> openFile(Map<String, dynamic> file) async {
    final path = file['path'];
    if (openFiles.any((f) => f['path'] == path)) {
      await switchFile(openFiles.firstWhere((f) => f['path'] == path));
      return;
    }

    log('> Decrypting file: ${file['name']}...');
    try {
      String content = await github.api.getFileContent(file['url']);
      content = content.replaceAll('\r', '');

      originalContents[path] = content;
      workingContents[path] = content;
      openFiles.add(file);
      currentFile = file;
      notify();

      await _injectFileToMonaco(file);
      log('> File decrypted successfully.');
    } catch (e) {
      log('> ERROR: File corruption detected - $e');
    }
  }

  Future<void> switchFile(Map<String, dynamic> file) async {
    if (currentFile?['path'] == file['path']) return;
    currentFile = file;
    notify();
    await _injectFileToMonaco(file);
  }

  Future<void> closeFile(Map<String, dynamic> file) async {
    final path = file['path'];
    openFiles.removeWhere((f) => f['path'] == path);
    originalContents.remove(path);
    workingContents.remove(path);
    modifiedFiles.remove(path);

    if (currentFile?['path'] == path) {
      if (openFiles.isNotEmpty) {
        await switchFile(openFiles.last);
      } else {
        currentFile = null;
        notify();
        if (webViewController != null) {
          await webViewController!.evaluateJavascript(
            source:
                "setContent('// Select a file from the databanks to begin.', 'javascript')",
          );
        }
      }
    } else {
      notify();
    }
  }

  Future<void> _injectFileToMonaco(Map<String, dynamic> file) async {
    if (webViewController == null) return;
    String lang = 'javascript';
    if (file['name'].endsWith('.dart')) lang = 'dart';
    if (file['name'].endsWith('.py')) lang = 'python';
    if (file['name'].endsWith('.html')) lang = 'html';

    String content =
        workingContents[file['path']] ?? originalContents[file['path']] ?? '';
    final escapedContent = content
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n');
    await webViewController!.evaluateJavascript(
      source: "setContent('$escapedContent', '$lang')",
    );
  }

  void onContentChanged(String newContent) {
    if (currentFile == null) return;
    final path = currentFile!['path'];
    workingContents[path] = newContent;

    final original = originalContents[path];
    final wasModified = modifiedFiles.containsKey(path);
    final isModified = original != null && original != newContent;

    if (isModified != wasModified) {
      if (isModified) {
        modifiedFiles[path] = currentFile!;
      } else {
        modifiedFiles.remove(path);
      }
      notify();
    }
  }

  Future<void> commitChanges(String _, String message) async {
    if (currentFile == null || github.currentRepo == null) return;
    log('> Commencing DEPLOY sequence...');
    try {
      await extensions.formatCode(webViewController);
      String newContent = '';
      if (webViewController != null) {
        final result = await webViewController!.evaluateJavascript(
          source: "getContent()",
        );
        newContent = result?.toString() ?? '';
      }

      currentFile!['sha'] = await github.api.commitFile(
        repoFullName: github.currentRepo!,
        path: currentFile!['path'],
        content: newContent,
        message: message,
        sha: currentFile!['sha'],
      );
      originalContents[currentFile!['path']] = newContent;
      workingContents[currentFile!['path']] = newContent;
      modifiedFiles.remove(currentFile!['path']);
      github.addCommitXp();
      log('> QUEST COMPLETE: Code deployed successfully (+50 XP)');
      notify();
      github.loadContents(github.currentRepo!, github.currentPath);
    } catch (e) {
      log('> ERROR: Deploy sequence failed - $e');
    }
  }
}
