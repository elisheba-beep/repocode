const String monacoHtml = """
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
        language: 'javascript', theme: 'vs-dark', automaticLayout: true, minimap: { enabled: true }
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
    function setTheme(themeName) { if(editor) { monaco.editor.setTheme(themeName); } }
    function formatDocument() { if(editor) { editor.getAction('editor.action.formatDocument').run(); } }
    function toggleLinter(enabled) {
      if(monaco) {
        monaco.languages.typescript.javascriptDefaults.setDiagnosticsOptions({
          noSemanticValidation: !enabled,
          noSyntaxValidation: !enabled
        });
      }
    }
  </script>
</body>
</html>
""";