import 'package:flutter/material.dart';
import 'services/github_service.dart';
import 'editor_screen.dart';

class RepoScreen extends StatefulWidget {
  final String repoFullName;
  final String path;

  const RepoScreen({super.key, required this.repoFullName, this.path = ''});

  @override
  State<RepoScreen> createState() => _RepoScreenState();
}

class _RepoScreenState extends State<RepoScreen> {
  final GitHubService _gitHubService = GitHubService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.isEmpty ? widget.repoFullName : widget.path),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _gitHubService.getContents(widget.repoFullName, widget.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isDir = item['type'] == 'dir';
              return ListTile(
                leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file),
                title: Text(item['name']),
                onTap: () {
                  if (isDir) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RepoScreen(
                          repoFullName: widget.repoFullName,
                          path: item['path'],
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditorScreen(
                          repoFullName: widget.repoFullName,
                          path: item['path'],
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
