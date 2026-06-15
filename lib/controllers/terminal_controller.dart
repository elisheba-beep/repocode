class TerminalController {
  final Function notify;

  List<String> logs = [
    '>>> TERMINAL UPLINK ESTABLISHED',
    '> Accessing GitHub Databanks...',
  ];

  TerminalController(this.notify);

  void log(String message) {
    if (message.isNotEmpty) {
      logs.add(message);
      if (logs.length > 100) logs.removeAt(0); // Prevent memory leaks
      notify();
    }
  }
}
