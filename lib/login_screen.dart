import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    final token = await _authService.getToken();
    if (token != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _startLogin() async {
    setState(() => _isLoading = true);
    try {
      final flowData = await _authService.startDeviceFlow();
      final verificationUri = Uri.parse(flowData['verification_uri']);
      if (await canLaunchUrl(verificationUri)) {
        await launchUrl(verificationUri);
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('GitHub Login'),
            content: SelectableText(
              '1. Go to: ${flowData['verification_uri']}\n'
              '2. Enter code: ${flowData['user_code']}\n\n'
              'Waiting for authorization...',
            ),
          ),
        );
      }

      final token = await _authService.pollForToken(
        flowData['device_code'],
        flowData['interval'],
      );

      if (token != null) {
        await _authService.saveToken(token);
        if (mounted) {
          Navigator.pop(context); // Close dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _startLogin,
                icon: const Icon(Icons.code),
                label: const Text('Login with GitHub'),
              ),
      ),
    );
  }
}
