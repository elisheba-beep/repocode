import 'dart:io';

class TerminalService {
  String _currentDirectory = Directory.current.path;

  String get currentDirectory => _currentDirectory;

  Future<String> executeCommand(String command) async {
    command = command.trim();
    if (command.isEmpty) return '';

    // Handle 'cd' commands internally to maintain persistent state
    if (command.startsWith('cd ') || command == 'cd') {
      final target = command
          .substring(command.startsWith('cd ') ? 3 : 2)
          .trim();
      if (target.isEmpty) return _currentDirectory;

      try {
        // Resolve the new path
        Uri currentUri = Uri.directory(_currentDirectory);
        Uri targetUri = currentUri.resolve(target);
        Directory newDir = Directory.fromUri(targetUri);

        if (await newDir.exists()) {
          _currentDirectory = newDir.path;
          return ''; // Success, no output needed
        } else {
          return 'Directory not found: $target';
        }
      } catch (e) {
        return 'Invalid directory: $e';
      }
    }

    try {
      final result = await Process.run(
        Platform.isWindows ? 'cmd' : 'bash',
        Platform.isWindows ? ['/c', command] : ['-c', command],
        workingDirectory: _currentDirectory,
        runInShell: true,
      );
      final out = result.stdout.toString().trim();
      final err = result.stderr.toString().trim();
      return out.isNotEmpty ? out : err;
    } catch (e) {
      return 'ERROR executing command: $e';
    }
  }
}
