import 'package:flutter/material.dart';
import '../../theme/cyber_theme.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EditorView extends StatelessWidget {
  final Map<String, dynamic>? currentFile;
  final int playerXp;
  final Function(InAppWebViewController) onWebViewCreated;
  final Function(String content, String message) onDeploy;
  final Function(String content)? onContentChanged;

  const EditorView({
    super.key,
    required this.currentFile,
    required this.playerXp,
    required this.onWebViewCreated,
    required this.onDeploy,
    this.onContentChanged,
  });

  final String _monacoHtml = """
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <style> body, html, #container { margin: 0; padding: 0; height: 100%; width: 100%; background-color: #09090E; } </style>
  </head>
  <body>
    <div id="container"></div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.40.0/min/vs/loader.min.js"></script>
    <script>
      require.config({ paths: { 'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.40.0/min/vs' }});
      var editor;
      require(['vs/editor/editor.main'], function() {
        editor = monaco.editor.create(document.getElementById('container'), {
          value: '// Select a file from the databanks to begin.',
          language: 'javascript', theme: 'vs-dark', automaticLayout: true, minimap: { enabled: false }
        });
        editor.onDidChangeModelContent(function() {
          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('onContentChanged', editor.getValue());
          }
        });
      });
      function setContent(content, lang) {
        if(editor) { monaco.editor.setModelLanguage(editor.getModel(), lang); editor.setValue(content); }
      }
      function getContent() { return editor ? editor.getValue() : ''; }
    </script>
  </body>
  </html>
  """;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cyberBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Tab
          Container(
            color: cyberPanel,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  currentFile?['name'] ?? 'NO_FILE_SELECTED',
                  style: glowingText(neonCyan),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.close, color: Colors.white54, size: 16),
              ],
            ),
          ),

          // XP Progression Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: neonCyan.withOpacity(0.6), blurRadius: 8),
              ],
            ),
            child: LinearProgressIndicator(
              value: (playerXp % 1000) / 1000.0,
              backgroundColor: cyberPanel,
              valueColor: const AlwaysStoppedAnimation<Color>(neonCyan),
            ),
          ),

          // Code Area
          Expanded(
            child: Stack(
              children: [
                // Grid Background
                CustomPaint(
                  painter: GridBackgroundPainter(),
                  child: Container(),
                ),

                InAppWebView(
                  initialData: InAppWebViewInitialData(data: _monacoHtml),
                  initialSettings: InAppWebViewSettings(
                    transparentBackground: true,
                  ),
                  onWebViewCreated: onWebViewCreated,
                ),

                // Floating Deploy Action Button
                if (currentFile != null)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: InkWell(
                      onTap: () async {
                        String commitMsg = currentFile != null
                            ? 'Update ${currentFile!['name']}'
                            : '';

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: cyberPanel,
                            title: Text(
                              'COMMIT CHANGES',
                              style: glowingText(neonMagenta),
                            ),
                            content: TextFormField(
                              initialValue: commitMsg,
                              onChanged: (val) => commitMsg = val,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Commit Message',
                                labelStyle: TextStyle(color: neonCyan),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: neonCyan),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'ABORT',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: neonMagenta,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // We retrieve the webViewController from the parent state via a callback to get content
                                  // Since this widget is stateless, we pass the execution up
                                  onDeploy('', commitMsg);
                                },
                                child: const Text(
                                  'EXECUTE DEPLOY',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: glowingBox(
                          neonMagenta,
                          isBorder: true,
                          opacity: 0.2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.rocket_launch, color: neonMagenta),
                            const SizedBox(width: 8),
                            Text(
                              'COMMIT CHANGES',
                              style: glowingText(
                                neonMagenta,
                                weight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = neonCyan.withOpacity(0.02)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 40)
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 40)
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
