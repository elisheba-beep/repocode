import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ExtensionController {
  final Function(String) log;
  final Function notify;

  List<Map<String, dynamic>> items = [
    {
      'name': 'Neon Syntax',
      'description': 'A high-contrast, vibrant theme.',
      'installed': true,
    },
    {
      'name': 'Prettier',
      'description': 'Formats your code on commit.',
      'installed': true,
    },
    {
      'name': 'Neural IntelliSense',
      'description': 'Inbuilt smart auto-completion & refactoring algorithms.',
      'installed': true,
    },
  ];

  ExtensionController(this.log, this.notify);

  void toggle(dynamic item, InAppWebViewController? webView) {
    final extIndex = items.indexWhere((e) => e['name'] == item['name']);
    if (extIndex != -1) {
      final ext = items[extIndex];
      ext['installed'] = !(ext['installed'] as bool);
      log(
        ext['installed']
            ? '> SYSTEM UPGRADE: ${ext['name']} enabled.'
            : '> SYSTEM DOWNGRADE: ${ext['name']} disabled.',
      );

      if (ext['name'] == 'Neon Syntax') applyTheme(webView);

      notify();
    }
  }

  void applyTheme(InAppWebViewController? webView) {
    if (webView == null) return;
    final isNeon =
        items.firstWhere((e) => e['name'] == 'Neon Syntax')['installed']
            as bool;
    webView.evaluateJavascript(
      source: "setTheme('${isNeon ? 'hc-black' : 'vs-dark'}')",
    );
  }

  Future<void> formatCode(InAppWebViewController? webView) async {
    if (webView == null) return;
    final isPrettier =
        items.firstWhere((e) => e['name'] == 'Prettier')['installed'] as bool;
    if (isPrettier) {
      log('> Formatting code with Prettier...');
      await webView.evaluateJavascript(source: "formatDocument()");
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}
