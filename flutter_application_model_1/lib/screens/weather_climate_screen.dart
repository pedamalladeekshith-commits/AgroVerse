import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/api_service.dart';

class WeatherClimateScreen extends StatefulWidget {
  const WeatherClimateScreen({super.key});

  @override
  State<WeatherClimateScreen> createState() => _WeatherClimateScreenState();
}

class _WeatherClimateScreenState extends State<WeatherClimateScreen> {
  Map<String, dynamic>? _weatherData;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      Position? position;
      try {
        position = await _determinePosition();
      } catch (_) {
        position = null;
      }

      final Map<String, dynamic> weather;
      if (position != null) {
        weather = await ApiService.getCurrentWeather(
          lat: position.latitude,
          lon: position.longitude,
        );
      } else {
        weather = await ApiService.getCurrentWeather(city: "Bangalore");
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _weatherData = weather;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather & Climate"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _weatherData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage ?? "Weather data unavailable.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_queue, size: 80, color: Colors.blue[700]),
                      const SizedBox(height: 20),
                      Text(
                        "${_weatherData!['temperature']} C",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _weatherData!['condition'] ?? "Unknown",
                        style: const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${_weatherData!['city']}, ${_weatherData!['region']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfo("Humidity", "${_weatherData!['humidity']}%"),
                              _buildInfo("Rainfall", "${_weatherData!['rainfall']} mm"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _fetchWeather,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh"),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
