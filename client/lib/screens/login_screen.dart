import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';
import 'ballot_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _voterIdController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_voterIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Voter ID')),
      );
      return;
    }

    // 1. Check for Biometrics Support
    final bool canAuthenticate = await _biometricService.isDeviceSupported();

    if (!canAuthenticate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This device does not support biometrics')),
      );
      return;
    }

    // 2. Authenticate with Biometrics
    final bool didAuthenticate = await _biometricService.authenticate();

    if (didAuthenticate) {
      _performBackendLogin();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication Failed')),
      );
    }
  }

  Future<void> _performBackendLogin() async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);

    try {
      final token = await api.authenticate(_voterIdController.text);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BallotScreen(token: token),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 32),
              TextField(
                controller: _voterIdController,
                decoration: const InputDecoration(
                  labelText: 'Voter ID',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your unique ID',
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Authenticate & Login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
