import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import 'pest_disease_detection_screen.dart';
import 'soil_prediction_screen.dart';
import 'farm_log_screen.dart';
import 'crop_recommendation_screen.dart';
import 'marketplace_screen.dart';
import 'government_schemes_screen.dart';
import 'shop_screen.dart';
import 'community_forum_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _marketData;
  bool _isLoading = true;
  bool _isInitialized = false; 
  String _currentCity = "Detecting...";
  String _userName = "Farmer";
  String _userLocation = "Karnataka";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return; 
    if (!mounted) return;
    
    debugPrint("Dashboard: Initializing App Data...");
    setState(() => _isLoading = true);
    
    try {
      // 1. Load local profile (Instant)
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      
      _userName = prefs.getString('user_name') ?? "Farmer";
      _userLocation = prefs.getString('user_location') ?? "Karnataka";

      // 2. Determine Location
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (!mounted) return;
      
      if (placemarks.isNotEmpty) {
        _currentCity = placemarks[0].locality ?? "Unknown Location";
      }

      // 3. Parallel Network Fetch (Fastest UX)
      debugPrint("Dashboard: Fetching weather and market data...");
      final results = await Future.wait([
        ApiService.getCurrentWeather(lat: position.latitude, lon: position.longitude),
        ApiService.getMarketPrices("rice", state: _userLocation.split(',').last.trim()),
      ]);

      if (mounted) {
        setState(() {
          _weatherData = results[0] as Map<String, dynamic>;
          _marketData = results[1] as Map<String, dynamic>;
          _isLoading = false;
          _isInitialized = true;
          debugPrint("Dashboard: Initialization complete.");
        });
      }
    } catch (e) {
      debugPrint("Dashboard Init Error: $e");
      if (mounted) {
        _fetchFallbackData();
      }
    }
  }

  Future<void> _fetchFallbackData() async {
    if (!mounted) return;
    debugPrint("Dashboard: Fetching fallback data...");
    try {
      final results = await Future.wait([
        ApiService.getCurrentWeather(city: "Bangalore"),
        ApiService.getMarketPrices("rice", state: "Karnataka"),
      ]);
      if (mounted) {
        setState(() {
          _weatherData = results[0] as Map<String, dynamic>;
          _marketData = results[1] as Map<String, dynamic>;
          _currentCity = "Bangalore (Default)";
          _isLoading = false;
          _isInitialized = true;
          debugPrint("Dashboard: Fallback data loaded.");
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // build() method should remain clean of logic
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroVerse Dashboard"),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _isInitialized = false;
          await _initializeApp();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back, $_userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const Text("How is your farm today?", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),
  
              _isLoading 
                ? _buildShimmerBox(height: 100)
                : _buildWeatherCard(),
              const SizedBox(height: 20),
  
              const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              _buildActionGrid(),
              const SizedBox(height: 20),
  
              const Text("Live Market Highlights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              _isLoading 
                ? _buildShimmerBox(height: 150)
                : _buildMarketHighlights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_weatherData == null) return const Card(child: ListTile(title: Text("Weather unavailable")));
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.blue[200]!, width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny, size: 50, color: Colors.orange),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Weather in $_currentCity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Temp: ${_weatherData!['temperature']} C | Hum: ${_weatherData!['humidity']}%"),
                Text("Condition: ${_weatherData!['condition']}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildActionCard(context, "Disease Detection", Icons.camera_alt, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PestDiseaseDetectionScreen()))),
        _buildActionCard(context, "Soil Test", Icons.terrain, Colors.brown, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilPredictionScreen()))),
        _buildActionCard(context, "Crop Advisory", Icons.grass, Colors.lightGreen, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropRecommendationScreen()))),
        _buildActionCard(context, "Market Prices", Icons.store, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen()))),
        _buildActionCard(context, "Schemes", Icons.policy, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernmentSchemesScreen()))),
        _buildActionCard(context, "Agro Shop", Icons.shopping_bag, Colors.deepOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()))),
        _buildActionCard(context, "Farm Log", Icons.edit_note, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmLogScreen()))),
        _buildActionCard(context, "Community", Icons.groups, Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityForumScreen()))),
      ],
    );
  }

  Widget _buildMarketHighlights() {
    if (_marketData == null) return const Card(child: ListTile(title: Text("Market data unavailable")));
    final records = _marketData!['market_comparison'] as List;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ...records.take(3).map((r) => ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: Text("${r['market']} Mandi"),
              subtitle: Text("${r['commodity']}"),
              trailing: Text("Rs ${r['price'] ?? r['modal_price'] ?? '--'} / ${r['unit'] ?? 'Qtl'}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            )).toList(),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
              child: const Text("View More Mandis"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 32, color: color)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
