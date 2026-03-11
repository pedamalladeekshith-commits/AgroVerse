import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  _GovernmentSchemesScreenState createState() => _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen> {
  bool _loading = false;
  List<dynamic> _allSchemes = [];
  String? _error;
  double _farmSize = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileAndSchemes();
  }

  Future<void> _loadProfileAndSchemes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _farmSize = double.tryParse(prefs.getString('farm_size') ?? "0") ?? 0;
    });
    _fetchSchemes();
  }

  Future<void> _fetchSchemes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getSchemes();
      setState(() {
        _allSchemes = result;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _openScheme(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      urlString = "https://www.google.com/search?q=government+farming+schemes+india";
    }
    
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open link: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Categorization Logic
    final recommended = _allSchemes.where((s) {
      if (s['target_farmer'] == 'small' && _farmSize < 5) return true;
      return false; 
    }).toList();

    final financial = _allSchemes.where((s) => s['category'] == 'Financial Support').toList();
    final insurance = _allSchemes.where((s) => s['category'] == 'Insurance').toList();
    final irrigation = _allSchemes.where((s) => s['category'] == 'Irrigation').toList();
    final other = _allSchemes.where((s) => !['Financial Support', 'Insurance', 'Irrigation'].contains(s['category'])).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Schemes & Support"),
        backgroundColor: Colors.green[800],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (recommended.isNotEmpty) ...[
                      _buildSectionHeader("Recommended For You", Icons.star, Colors.orange),
                      ...recommended.map((s) => _buildSchemeCard(s, true)),
                      const SizedBox(height: 20),
                    ],
                    
                    _buildSectionHeader("Financial Support", Icons.account_balance_wallet, Colors.blue),
                    ...financial.map((s) => _buildSchemeCard(s, false)),
                    const SizedBox(height: 20),

                    _buildSectionHeader("Insurance", Icons.security, Colors.purple),
                    ...insurance.map((s) => _buildSchemeCard(s, false)),
                    const SizedBox(height: 20),

                    _buildSectionHeader("Irrigation & Infrastructure", Icons.water_drop, Colors.cyan),
                    ...irrigation.map((s) => _buildSchemeCard(s, false)),
                    const SizedBox(height: 20),

                    _buildSectionHeader("Other Support", Icons.more_horiz, Colors.grey),
                    ...other.map((s) => _buildSchemeCard(s, false)),
                  ],
                ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(dynamic scheme, bool isRecommended) {
    bool isEligible = true;
    if (scheme['target_farmer'] == 'small' && _farmSize > 5) isEligible = false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(scheme['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(scheme['category'], style: TextStyle(color: Colors.green[700])),
            if (isEligible)
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text("You are likely eligible", style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              )
            else
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text("Check eligibility rules", style: TextStyle(color: Colors.orange, fontSize: 12)),
                ],
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(scheme['description']),
                const SizedBox(height: 12),
                const Text("Key Benefits", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(scheme['benefits']),
                const SizedBox(height: 12),
                const Text("Eligibility", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(scheme['eligibility']),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openScheme(scheme['link']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    child: const Text("Apply on Official Website", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
