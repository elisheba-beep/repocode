import 'dart:math' as math;
import '../services/github_service.dart';
import '../services/auth_service.dart';

class GithubController {
  final GitHubService api = GitHubService();
  final AuthService _authService = AuthService();
  final Function(String) log;
  final Function notify;

  List<dynamic> sidebarItems = [];
  bool showingRepos = true;
  String? currentRepo;
  String currentPath = '';

  String username = 'Uplinking...';
  int totalCommits = 0;
  double integrity = 0.0;
  int playerXp = 150;

  GithubController(this.log, this.notify) {
    _loadRepos();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await api.getUserProfile();
      username = profile['login'];
      totalCommits = await api.getUserCommits(username);
      integrity = math.min(100.0, math.sqrt(totalCommits));
      notify();
    } catch (e) {
      log('> ERROR: Failed to fetch profile stats.');
    }
  }

  Future<void> _loadRepos() async {
    sidebarItems = [];
    notify();
    try {
      final repos = await api.getRepos();
      sidebarItems = repos;
      showingRepos = true;
      currentRepo = null;
      currentPath = '';
      log('> Databanks synced: ${repos.length} repositories found.');
      notify();
    } catch (e) {
      log('> ERROR: Failed to fetch repos - $e');
    }
  }

  Future<void> loadContents(String repoFullName, [String path = '']) async {
    sidebarItems = [];
    notify();
    try {
      final contents = await api.getContents(repoFullName, path);
      sidebarItems = contents;
      showingRepos = false;
      currentRepo = repoFullName;
      currentPath = path;
      log('> Directory accessed: /$path');
      notify();
    } catch (e) {
      log('> ERROR: Directory locked - $e');
    }
  }

  void handleBack() {
    if (currentPath.isEmpty) {
      _loadRepos();
    } else {
      final parts = currentPath.split('/');
      parts.removeLast();
      loadContents(currentRepo!, parts.join('/'));
    }
  }

  void addCommitXp() {
    playerXp += 50;
    totalCommits += 1;
    integrity = math.min(100.0, math.sqrt(totalCommits));
    notify();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}