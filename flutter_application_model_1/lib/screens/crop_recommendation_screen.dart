import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  _CropRecommendationScreenState createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  String? _primaryCrop;
  List<String> _alternativeCrops = [];
  Map<String, String> _overview = {};
  bool _loading = false;

  Future<void> _getRecommendation() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://YOUR_IP_ADDRESS:5000/recommend'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'soil_type': 'Loamy',
          'climate': 'Tropical',
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          _primaryCrop = decoded['primary_crop'];
          _alternativeCrops =
              List<String>.from(decoded['alternative_crops']);
          _overview = Map<String, String>.from(decoded['overview']);
        });
      }
    } catch (e) {
      // Handle error
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
        title: const Text("AI Crop Recommendation"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: _getRecommendation,
            child: const Text('Get Recommendation'),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_primaryCrop != null) ...[
            const Text(
              "Recommended Crops",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Chip(
              avatar: const Icon(Icons.grass),
              label: Text(_primaryCrop!),
            ),
            const SizedBox(height: 10),
            const Text(
              "Alternative Crops",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: _alternativeCrops
                  .map((crop) => Chip(
                        avatar: const Icon(Icons.grass),
                        label: Text(crop),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._overview.entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.info),
                title: Text(entry.key),
                subtitle: Text(entry.value),
              ),
            ),
          ] else ...[
            Card(
              color: Colors.green[100],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Recommendation based on soil, climate, and past yield.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Factors Analyzed",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.cloud),
              title: Text("Climate Data"),
            ),
            const ListTile(
              leading: Icon(Icons.terrain),
              title: Text("Soil Type"),
            ),
            const ListTile(
              leading: Icon(Icons.history),
              title: Text("Past Yield"),
            ),
          ]
        ],
      ),
    );
  }
}
