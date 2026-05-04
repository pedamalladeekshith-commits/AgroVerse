import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';
import 'shop_screen.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  _CropRecommendationScreenState createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _cityController = TextEditingController();
  
  // Default values are now based on typical soil test ranges (medium fertility)
  double _nValue = 80; // Medium Nitrogen (ppm)
  double _pValue = 60; // Medium Phosphorus (ppm)
  double _kValue = 100; // Medium Potassium (ppm)
  double _phValue = 6.5; // Neutral pH (optimal for most crops)
  double _landSize = 1.0; // 1 acre default

  Map<String, dynamic>? _recommendation;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    try {
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _cityController.text = placemarks[0].locality ?? "";
        });
      }
    } catch (e) {
      debugPrint("Auto-location failed: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getRecommendation() async {
    if (_cityController.text.isEmpty) {
      setState(() => _error = "Please enter your city/location.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _recommendation = null;
    });

    try {
      final result = await ApiService.recommendCrop(
        n: _nValue,
        p: _pValue,
        k: _kValue,
        ph: _phValue,
        city: _cityController.text,
        landSize: _landSize,
      );
      setState(() {
        _recommendation = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Advisory"),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Crop Advisory - AI Powered",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Get personalized crop recommendations based on your soil test results",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Soil Test Guidance Card
            Card(
              color: Colors.blue[50],
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "About Soil Testing",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Values below are soil nutrient levels from your soil test report:\n"
                      "- N (Nitrogen): mg/kg or ppm\n"
                      "- P (Phosphorus): mg/kg or ppm\n"
                      "- K (Potassium): mg/kg or ppm\n"
                      "- pH: Soil acidity (3-10 scale)\n\n"
                      "Get a soil test from your agriculture office for accurate results!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Enter Your Soil Test Results",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildSlider(
              "Nitrogen (N)",
              _nValue,
              0,
              140,
              (val) => setState(() => _nValue = val),
              helpText: "Typical: 40-100 (Low-High)",
            ),
            _buildSlider(
              "Phosphorus (P)",
              _pValue,
              0,
              140,
              (val) => setState(() => _pValue = val),
              helpText: "Typical: 20-80 (Low-High)",
            ),
            _buildSlider(
              "Potassium (K)",
              _kValue,
              0,
              205,
              (val) => setState(() => _kValue = val),
              helpText: "Typical: 50-200 (Low-High)",
            ),
            _buildSlider(
              "Soil pH",
              _phValue,
              0,
              14,
              (val) => setState(() => _phValue = val),
              divisions: 140,
              helpText: "6.0-7.5 is optimal for most crops",
            ),
            _buildSlider(
              "Land Size (Acres)",
              _landSize,
              0.1,
              50,
              (val) => setState(() => _landSize = val),
              divisions: 499,
            ),

            const SizedBox(height: 10),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City/Location',
                hintText: 'e.g., Mumbai, Delhi, Punjab',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_city),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _detectLocation,
                  tooltip: "Auto-detect location",
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _getRecommendation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Get AI Crop Recommendation',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 10),

            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],

            if (_recommendation != null) ...[
              const SizedBox(height: 30),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text(
                "AI Advisory Result",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label: ${value.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (helpText != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  helpText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? (max - min).toInt(),
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final rec = _recommendation!;
    final market = rec['market_intelligence']?['best_market'] ?? {};
    final weather = rec['weather_summary'] ?? {};
    final pestAlerts = rec['pest_alerts'] ?? [];
    final cropDetails = rec['crop_details'] ?? {};
    final alternativeCrops = rec['alternative_crops'] is List
        ? rec['alternative_crops'] as List
        : [];

    return Column(
      children: [
        // Crop Recommendation
        Card(
          color: Colors.green[50],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(Icons.eco, size: 50, color: Colors.green),
                title: const Text(
                  "Recommended Crop",
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  rec['recommended_crop'] ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Confidence", style: TextStyle(fontSize: 12)),
                    Text(
                      "${rec['confidence'] ?? '0%'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopScreen(
                            product: "${rec['recommended_crop']} Seeds",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: Text("Buy ${rec['recommended_crop']} Seeds"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (alternativeCrops.isNotEmpty)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.grass, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Other Suitable Crops",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  for (final crop in alternativeCrops.take(4))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.eco, color: Colors.green),
                      title: Text(
                        "${crop['crop'] ?? 'Crop'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        [
                          if (crop['soil_ph'] != null)
                            "pH ${crop['soil_ph']}",
                          if (crop['duration'] != null)
                            "${crop['duration']}",
                        ].join(" | "),
                      ),
                      trailing: Text(
                        "${crop['confidence'] ?? ''}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (alternativeCrops.isNotEmpty) const SizedBox(height: 10),

        // AI INSIGHT SECTION
        Card(
          color: Colors.blue[50],
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "AI Insight: Why this crop?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  rec['explanation'] ??
                      "Recommended based on optimal soil nutrient levels and regional climate patterns.",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Quick Farming Guide
        if (cropDetails.isNotEmpty)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        "Quick Farming Guide",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text("Duration: ${cropDetails['duration'] ?? 'N/A'}"),
                  Text("Ideal Soil pH: ${cropDetails['soil_ph'] ?? 'N/A'}"),
                  if (cropDetails['tips'] != null &&
                      (cropDetails['tips'] as List).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Tip: ${(cropDetails['tips'] as List).first}",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),

        // Regional Insight
        Card(
          color: Colors.blue[50],
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text(
                      "Regional History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                if (rec['regional_insight'] != null && rec['regional_insight']['note'] != null)
                  Text(rec['regional_insight']['note'])
                else if (rec['regional_insight'] != null) ...[
                  Text(
                    "Historical Yield: ${rec['regional_insight']['historical_yield_in_district']} Tonnes/Hectare",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Suitability: ${rec['regional_insight']['suitability']}",
                    style: TextStyle(
                      color:
                          rec['regional_insight']['suitability'].toString().contains(
                                "High",
                              )
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Top Regional Performer: ${rec['regional_insight']['regional_top_performer']} (${rec['regional_insight']['regional_top_yield']} T/H)",
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Market & Revenue
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.currency_rupee, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Market Intelligence",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  "Best Mandi: ${market['market'] ?? 'N/A'} (${market['district'] ?? ''})",
                ),
                Text(
                  "Modal Price: Rs ${market['price'] ?? '0'} / ${market['unit'] ?? 'Qtl'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Estimated Yield: ${rec['estimated_yield_tons'] ?? 'N/A'} Tons",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Potential Revenue: Rs ${rec['market_intelligence']?['estimated_revenue'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Weather
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cloud, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Weather Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  "Temperature: ${weather['avg_temp']?.toStringAsFixed(1) ?? 'N/A'} C",
                ),
                Text(
                  "Rainfall: ${weather['total_rainfall']?.toStringAsFixed(1) ?? 'N/A'}mm",
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Pest Alerts
        if (pestAlerts.isNotEmpty)
          Card(
            color: Colors.red[50],
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Pest Risk Alert",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  for (var alert in pestAlerts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pest: ${alert['pest']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Risk Level: ${alert['risk_level']}",
                            style: const TextStyle(color: Colors.red),
                          ),
                          Text(
                            "Recommended Action: ${alert['recommendation']}",
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
