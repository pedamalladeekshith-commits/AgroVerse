import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCommodity = 'Wheat';
  String _selectedState = 'Karnataka';
  String _farmSize = "5.0";

  final List<String> _commodities = ['Wheat', 'Rice', 'Tomato', 'Potato', 'Onion', 'Cotton', 'Maize'];
  final List<String> _states = ['Karnataka', 'Maharashtra', 'Punjab', 'Gujarat', 'Uttar Pradesh'];

  bool _loading = false;
  bool _isInitialized = false;
  Map<String, dynamic>? _marketData;
  String? _error;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadProfileAndFetch();
  }

  Future<void> _loadProfileAndFetch() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _farmSize = prefs.getString('farm_size') ?? "5.0";
      _selectedState = (prefs.getString('user_location') ?? "Karnataka").split(',').last.trim();
      if (!_states.contains(_selectedState)) {
        _selectedState = "Karnataka";
      }
    });
    _fetchMarket();
  }

  Future<void> _fetchMarket() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _marketData = null;
    });

    try {
      final result = await ApiService.getMarketPrices(
        _selectedCommodity, 
        state: _selectedState,
      );
      if (mounted) {
        setState(() {
          _marketData = result;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Intelligence"),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCommodity,
                    decoration: const InputDecoration(labelText: "Crop", border: OutlineInputBorder()),
                    items: _commodities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCommodity = val);
                        // Trigger fetch manually on change
                        _isInitialized = false; 
                        _fetchMarket();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(labelText: "State", border: OutlineInputBorder()),
                    items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedState = val);
                        // Trigger fetch manually on change
                        _isInitialized = false;
                        _fetchMarket();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _isInitialized = false;
                _fetchMarket();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Analyze Profit & Trends", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            
            if (_loading)
              Expanded(child: _buildShimmerLoading())
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
            else if (_marketData != null)
              Expanded(
                child: ListView(
                  children: [
                    _buildBestMarketCard(),
                    const SizedBox(height: 20),
                    _buildForecastChart(),
                    const SizedBox(height: 20),
                    const Text(
                      "Nearby Mandi Comparison",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...(_marketData!['market_comparison'] as List).map((m) => Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.storefront, color: Colors.orange),
                        title: Text(m['market'] ?? 'Unknown Mandi', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${m['district'] ?? 'Local'}, ${m['state'] ?? 'State'}"),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Rs ${m['price'] ?? m['modal_price'] ?? '--'}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("per ${m['unit'] ?? 'Qtl'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastChart() {
    final forecast = _marketData!['price_forecast'];
    if (forecast == null) return const SizedBox();

    final List<dynamic> prices = forecast['predicted_prices'] ?? [];
    if (prices.isEmpty) return const SizedBox();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.blue),
                const SizedBox(width: 8),
                const Text("AI Price Forecast (Next 7 Days)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: forecast['trend'] == 'upward' ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    forecast['trend'].toString().toUpperCase(),
                    style: TextStyle(
                      color: forecast['trend'] == 'upward' ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(prices.length, (i) => FlSpot(i.toDouble(), prices[i].toDouble())),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      forecast['recommendation'] ?? "Stable market trend observed.",
                      style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestMarketCard() {
    final best = _marketData!['best_market'];
    if (best == null) return const SizedBox();

    final double revenue = (best['estimated_revenue'] ?? 0).toDouble();
    final modalPrice = best['price'] ?? best['modal_price'] ?? 0;

    return Card(
      color: Colors.green[50],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.green, width: 1)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.stars, color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text("Smart Profit Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
            const Divider(color: Colors.green),
            Text("Best Mandi: ${best['market']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip("Price", "Rs $modalPrice/Qtl"),
                _buildInfoChip("Yield", "2.0 Tons/Acre"),
                _buildInfoChip("Size", "$_farmSize Acres"),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ESTIMATED REVENUE", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
                      Text("Total Profit Potential", style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  Text(currencyFormat.format(revenue), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
