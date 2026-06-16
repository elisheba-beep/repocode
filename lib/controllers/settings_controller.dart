import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SettingsController {
  final Function notify;

  bool minigameEnabled = false;
  String currentTheme =
      'Neon Cyan'; // Options: Neon Cyan, Toxic Magenta, Matrix Green
  bool activeEditorEnabled = false;

  SettingsController(this.notify);

  void toggleMinigame() {
    minigameEnabled = !minigameEnabled;
    notify();
  }

  void setTheme(String theme, InAppWebViewController? webView) {
    currentTheme = theme;
    if (webView != null) {
      if (theme == 'Neon Cyan') {
        webView.evaluateJavascript(source: "setTheme('vs-dark')");
      } else if (theme == 'Toxic Magenta') {
        webView.evaluateJavascript(source: "setTheme('hc-black')");
      } else if (theme == 'Matrix Green') {
        // Using Monaco's light theme as a visual contrast substitute
        webView.evaluateJavascript(source: "setTheme('vs')");
      }
    }
    notify();
  }

  void toggleActiveEditor() {
    activeEditorEnabled = !activeEditorEnabled;
    notify();
  }

  List<dynamic> get items => [
    {
      'type': 'toggle',
      'name': 'Random Minigames',
      'value': minigameEnabled,
      'action': 'minigame',
    },
    {
      'type': 'select',
      'name': 'Theme Color',
      'value': currentTheme,
      'options': ['Neon Cyan', 'Toxic Magenta', 'Matrix Green'],
      'action': 'theme',
    },
    {
      'type': 'toggle',
      'name': 'Active Editor (+XP)',
      'value': activeEditorEnabled,
      'action': 'active_editor',
    },
  ];
}
