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
  List<Map<String, String>> _candidates = [];
  bool _isLoading = true;
  String? _selectedCandidateId;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    final api = Provider.of<ApiService>(context, listen: false);
    try {
      final candidates = await api.getCandidates();
      setState(() {
        _candidates = candidates;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading candidates: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateId == null) return;
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await api.castVote(widget.token, _selectedCandidateId!);
      
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Your vote has been cast successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Go back to login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voting failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Official Ballot')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _candidates.length,
              itemBuilder: (context, index) {
                final candidate = _candidates[index];
                final isSelected = _selectedCandidateId == candidate['id'];
                return Card(
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected ? Colors.deepPurple : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(candidate['name']![0]),
                    ),
                    title: Text(candidate['name']!),
                    subtitle: Text(candidate['party']!),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.deepPurple)
                        : const Icon(Icons.circle_outlined),
                    onTap: () {
                      setState(() {
                        _selectedCandidateId = candidate['id'];
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: _selectedCandidateId != null && !_isLoading
          ? FloatingActionButton.extended(
              onPressed: _submitVote,
              label: const Text('Cast Vote'),
              icon: const Icon(Icons.how_to_vote),
            )
          : null,
    );
  }
}
