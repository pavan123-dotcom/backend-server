import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final FocusNode _voterIdFocusNode = FocusNode(); 
  
  bool _isLoading = false;
  int _remainingAttempts = 3; 

  @override
  void initState() {
    super.initState();
    _voterIdFocusNode.addListener(() {
      if (!_voterIdFocusNode.hasFocus) {
        _updateRemainingAttempts();
      }
    });
  }

  @override
  void dispose() {
    _voterIdController.dispose();
    _voterIdFocusNode.dispose();
    super.dispose();
  }

  // --- LOGIC: CHECK ATTEMPTS ---
  Future<void> _updateRemainingAttempts() async {
    final voterId = _voterIdController.text.trim();
    if (voterId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'login_count_$voterId';
    int currentUsed = prefs.getInt(key) ?? 0;
    
    setState(() {
      _remainingAttempts = (3 - currentUsed).clamp(0, 3);
    });
  }

  // --- LOGIC: LOGIN FLOW ---
  Future<void> _handleLogin() async {
    await _updateRemainingAttempts();
    final voterId = _voterIdController.text.trim();
    
    if (voterId.isEmpty) {
      _showAttractiveDialog("Missing Input", "Please enter your Voter ID.", Colors.orange, Icons.warning_amber_rounded);
      return;
    }

    if (_remainingAttempts <= 0) {
      _showAttractiveDialog("Access Denied", "Maximum login attempts exceeded.\nContact Election Officer.", Colors.red, Icons.block);
      return; 
    }

    final bool canAuthenticate = await _biometricService.isDeviceSupported();
    if (!canAuthenticate) {
       _showAttractiveDialog("Not Supported", "Device does not support biometrics.", Colors.red, Icons.phonelink_erase_rounded);
      return;
    }

    final bool didAuthenticate = await _biometricService.authenticate();
    if (didAuthenticate) {
      _performBackendLogin(voterId);
    } else {
      if (!mounted) return;
       _showAttractiveDialog("Authentication Failed", "Biometric verification failed.", Colors.red, Icons.fingerprint);
    }
  }

  Future<void> _performBackendLogin(String voterId) async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);

    try {
      final token = await api.authenticate(voterId);
      
      // SUCCESS: Update Count
      final prefs = await SharedPreferences.getInstance();
      final String key = 'login_count_$voterId';
      int currentUsed = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, currentUsed + 1);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BallotScreen(token: token)),
      );

    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString();

      if (errorMessage.contains("403")) {
        _showAttractiveDialog("Vote Already Cast", "You have already voted. Access locked.", Colors.deepOrange, Icons.how_to_vote_rounded);
      } else if (errorMessage.contains("SocketException")) {
        _showAttractiveDialog("Connection Error", "No Internet Connection.", Colors.red, Icons.signal_wifi_off_rounded);
      } else {
        _showAttractiveDialog("Login Failed", "Invalid credentials or Server Error.", Colors.red, Icons.error_outline_rounded);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAttractiveDialog(String title, String message, Color color, IconData icon) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 20),
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 15),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
                child: const Text("Okay"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF8E24AA)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Image.asset('assets/images/app_logo.png', height: 100, width: 100),
                ),
                const SizedBox(height: 30),
                const Text("Election Commission of India", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 50),
                
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      const Text("Secure Login", style: TextStyle(color: Color(0xFF1A237E), fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _voterIdController,
                        focusNode: _voterIdFocusNode,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: "Voter ID",
                          hintText: "Enter ID & tap outside",
                          prefixIcon: const Icon(Icons.badge, color: Color(0xFF1A237E)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Authenticate & Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // --- NEW VERY ATTRACTIVE COUNTER (SHIELD DESIGN) ---
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "SECURITY STATUS",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                // Logic: Show shields. 
                                // 0,1,2 (All 3) active if remaining is 3.
                                bool isActive = index < _remainingAttempts;
                                Color shieldColor = _remainingAttempts > 1 ? Colors.green : Colors.red;
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: AnimatedScale(
                                    scale: isActive ? 1.0 : 0.8,
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      isActive ? Icons.security : Icons.gpp_bad_outlined,
                                      color: isActive ? shieldColor : Colors.grey.shade300,
                                      size: 32,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$_remainingAttempts Attempts Remaining",
                              style: TextStyle(
                                color: _remainingAttempts > 1 ? Colors.green.shade700 : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13
                              ),
                            ),
                          ],
                        ),
                      ),
                      // --- END NEW DESIGN ---
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}