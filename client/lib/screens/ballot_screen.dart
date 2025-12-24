import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class BallotScreen extends StatefulWidget {
  final String token;
  const BallotScreen({super.key, required this.token});

  @override
  State<BallotScreen> createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> {
  // --- CANDIDATES LIST ---
  final List<Map<String, dynamic>> _candidates = [
    {
      'id': '1', 
      'name': 'Narendra Modi', 
      'party': 'Bharatiya Janata Party (BJP)', 
      'logo': 'assets/images/party_a.png', 
      'color': Colors.orange,
    },
    {
      'id': '2',
      'name': 'Rahul Gandhi', 
      'party': 'Indian National Congress (INC)', 
      'logo': 'assets/images/party_b.png', 
      'color': Colors.blue,
    },
  ];

  bool _isLoading = false;
  String? _selectedCandidateId;

  // --- LOGOUT FUNCTION ---
  void _handleLogout() {
    // Navigate back to Login Screen cleanly
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateId == null) return;
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await api.castVote(widget.token, _selectedCandidateId!);
      
      if (!mounted) return;
      
      // Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text('Vote Success!'),
            ],
          ),
          content: const Text('Your vote has been recorded securely.', textAlign: TextAlign.center),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  backgroundColor: Colors.green
                ),
                onPressed: () {
                  Navigator.pop(ctx); 
                  _handleLogout(); // Auto-logout after voting
                },
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      // Error Dialog
       showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Vote Failed"),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Cast Your Vote', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0,
        automaticallyImplyLeading: false, // Hides the back button (Security)
        // --- THIS IS THE LOGOUT BUTTON ---
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.white),
              tooltip: 'Logout',
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB), // Deep Purple
              Color(0xFF2575FC), // Bright Blue
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  const SizedBox(height: 100), // Space for AppBar
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Choose your leader wisely",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // --- CANDIDATE CARDS ---
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = _candidates[index];
                        final isSelected = _selectedCandidateId == candidate['id'];
                        
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCandidateId = candidate['id']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected 
                                ? Border.all(color: Colors.amber, width: 3) 
                                : Border.all(color: Colors.transparent),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Logo
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade200),
                                    image: DecorationImage(
                                      image: AssetImage(candidate['logo']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Text Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        candidate['name'],
                                        style: const TextStyle(
                                          fontSize: 20, 
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        candidate['party'],
                                        style: TextStyle(
                                          color: candidate['color'], 
                                          fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Checkbox Icon
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Colors.green, size: 30)
                                else
                                  const Icon(Icons.circle_outlined, color: Colors.grey, size: 30),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      
      // --- CONFIRM BUTTON ---
      bottomNavigationBar: _selectedCandidateId != null && !_isLoading
          ? Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: _submitVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB), 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'CONFIRM VOTE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}