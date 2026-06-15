import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class GitHubService {
  final AuthService _authService = AuthService();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('https://api.github.com/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load user profile');
  }

  Future<int> getUserCommits(String username) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('https://api.github.com/search/commits?q=author:$username'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_count'] ?? 0;
    }
    return 0; // Return 0 safely if rate-limited or unavailable
  }

  Future<List<dynamic>> getRepos() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('https://api.github.com/user/repos?sort=updated'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load repositories');
  }

  Future<List<dynamic>> getContents(
    String repoFullName, [
    String path = '',
  ]) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$repoFullName/contents/$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? data : [data];
    }
    throw Exception('Failed to load folder contents');
  }

  Future<Map<String, dynamic>> getFile(String repoFullName, String path) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$repoFullName/contents/$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['type'] == 'file' && data.containsKey('content')) {
        String content = data['content'].replaceAll('\n', '');
        data['content'] = utf8.decode(base64Decode(content));
      }
      return data;
    }
    throw Exception('Failed to load file');
  }

  Future<String> getFileContent(String url) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3.raw',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Failed to load file content');
  }

  Future<String> commitFile({
    required String repoFullName,
    required String path,
    required String content,
    required String message,
    required String sha,
  }) async {
    final token = await _getToken();
    final body = jsonEncode({
      'message': message,
      'content': base64Encode(utf8.encode(content)),
      'sha': sha,
    });

    try {
      final response = await http
          .put(
            Uri.parse(
              'https://api.github.com/repos/$repoFullName/contents/$path',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/vnd.github.v3+json',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['content']['sha'];
      } else {
        throw Exception('Failed to commit: ${response.body}');
      }
    } on SocketException catch (_) {
      throw Exception('UPLINK SEVERED: Network connection dropped.');
    } on TimeoutException catch (_) {
      throw Exception('REQUEST TIMEOUT: GitHub API took too long to respond.');
    } on http.ClientException catch (e) {
      throw Exception(
        'NETWORK ERROR: Unable to communicate with the GitHub databanks (${e.message}).',
      );
    } catch (e) {
      throw Exception('DEPLOY FAILED: $e');
    }
  }
}
