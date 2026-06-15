import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'services/github_service.dart';

class EditorScreen extends StatefulWidget {
  final String repoFullName;
  final String path;

  const EditorScreen({
    super.key,
    required this.repoFullName,
    required this.path,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GitHubService _gitHubService = GitHubService();
  InAppWebViewController? _webViewController;

  bool _isLoading = true;
  String? _fileSha;
  String? _initialContent;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final fileData = await _gitHubService.getFile(
        widget.repoFullName,
        widget.path,
      );
      setState(() {
        _initialContent = fileData['content'];
        _fileSha = fileData['sha'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  String _getLanguageFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'js':
        return 'javascript';
      case 'ts':
        return 'typescript';
      case 'dart':
        return 'dart';
      case 'json':
        return 'json';
      case 'html':
        return 'html';
      case 'css':
        return 'css';
      case 'md':
        return 'markdown';
      case 'py':
        return 'python';
      case 'cpp':
        return 'cpp';
      default:
        return 'plaintext';
    }
  }

  Future<void> _promptCommit() async {
    if (_webViewController == null || _fileSha == null) return;

    // Get the current code from Monaco via JS evaluation
    final codeResult = await _webViewController!.evaluateJavascript(
      source: "window.editor.getValue();",
    );
    final String updatedCode = codeResult.toString();

    final fileName = widget.path.split('/').last;
    String commitMessage = 'Update $fileName';

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        String tempMsg = commitMessage;
        return AlertDialog(
          title: const Text('Commit Changes'),
          content: TextFormField(
            initialValue: commitMessage,
            decoration: const InputDecoration(labelText: 'Commit Message'),
            onChanged: (val) => tempMsg = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                commitMessage = tempMsg;
                Navigator.pop(context, true);
              },
              child: const Text('Commit'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _gitHubService.commitFile(
          repoFullName: widget.repoFullName,
          path: widget.path,
          content: updatedCode,
          message: commitMessage,
          sha: _fileSha!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully committed changes!')),
          );
          Navigator.pop(context); // Go back after save
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Commit failed: $e')));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String get _monacoHtml {
    final language = _getLanguageFromPath(widget.path);
    final safeContent = jsonEncode(_initialContent ?? '');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Monaco Editor</title>
      <style>
        html, body { height: 100%; margin: 0; padding: 0; overflow: hidden; background-color: #1e1e1e; }
        #container { width: 100%; height: 100%; }
      </style>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js"></script>
    </head>
    <body>
      <div id="container"></div>
      <script>
        require.config({ paths: { 'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.34.1/min/vs' }});
        require(['vs/editor/editor.main'], function() {
          window.editor = monaco.editor.create(document.getElementById('container'), {
            value: $safeContent,
            language: '$language',
            theme: 'vs-dark',
            automaticLayout: true
          });
        });
      </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split('/').last),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _promptCommit,
              tooltip: 'Commit changes',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : InAppWebView(
              initialData: InAppWebViewInitialData(data: _monacoHtml),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
            ),
    );
  }
}
