import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'github_access_token';

  static String get _clientId => dotenv.env['GITHUB_CLIENT_ID'] ?? '';

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<Map<String, dynamic>> startDeviceFlow() async {
    final response = await http.post(
      Uri.parse('https://github.com/login/device/code'),
      headers: {'Accept': 'application/json'},
      body: {'client_id': _clientId, 'scope': 'repo'},
    );
    final data = jsonDecode(response.body);
    if (data.containsKey('error')) {
      throw Exception(
        data['error_description'] ?? 'Invalid Client ID or API Error',
      );
    }
    return data;
  }

  Future<String?> pollForToken(String deviceCode, int interval) async {
    while (true) {
      await Future.delayed(Duration(seconds: interval));
      final response = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {'Accept': 'application/json'},
        body: {
          'client_id': _clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      );

      final data = jsonDecode(response.body);
      if (data.containsKey('access_token')) {
        return data['access_token'];
      }
    }
  }
}
