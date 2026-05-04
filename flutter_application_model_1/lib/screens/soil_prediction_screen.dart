import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class SoilPredictionScreen extends StatefulWidget {
  const SoilPredictionScreen({super.key});

  @override
  _SoilPredictionScreenState createState() => _SoilPredictionScreenState();
}

class _SoilPredictionScreenState extends State<SoilPredictionScreen> {
  File? _image;
  final picker = ImagePicker();
  String? _soilType;
  String? _confidence;
  bool _loading = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _soilType = null;
        _confidence = null;
        _error = null;
      });
      _analyzeSoil();
    }
  }

  Future<void> _analyzeSoil() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiService.predictSoil(_image!);
      setState(() {
        _soilType = response['soil_type'];
        _confidence = response['confidence'];
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
        title: const Text("Soil Analysis"),
        backgroundColor: Colors.brown[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Identify your soil type using AI for better crop selection.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Image Display
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.brown[50],
                border: Border.all(color: Colors.brown, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.terrain, size: 80, color: Colors.brown[300]),
                        const SizedBox(height: 10),
                        const Text("No Image Selected", style: TextStyle(fontSize: 16)),
                      ],
                    ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 28),
                    label: const Text("Camera", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.brown[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 28),
                    label: const Text("Gallery", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Result Display
            if (_loading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16))
            else if (_soilType != null)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text("Soil Type Detected", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        _soilType!,
                        style: const TextStyle(fontSize: 24, color: Colors.brown, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      
                      // CONFIDENCE METER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: double.tryParse(_confidence?.replaceAll('%', '') ?? '0') != null ? (double.parse(_confidence!.replaceAll('%', '')) / 100) : 0,
                                backgroundColor: Colors.grey[200],
                                color: Colors.brown,
                                strokeWidth: 6,
                              ),
                              Text(
                                _confidence ?? "0%",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          const Text("Confidence Score", style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      
                      const Divider(height: 30),
                      const Text(
                        "Quick Advice",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getSoilAdvice(_soilType!),
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getSoilAdvice(String type) {
    switch (type.toLowerCase()) {
      case 'alluvial':
      case 'alluvial soil': return "Excellent for rice, wheat, and sugarcane. Highly fertile.";
      case 'black':
      case 'black soil': return "Best for cotton and oilseeds. Retains moisture well.";
      case 'clayey': return "Good for water-intensive crops like paddy. Needs drainage.";
      case 'laterite': return "Suitable for tea, coffee, and cashew nuts with proper fertilization.";
      case 'loamy': return "Ideal for most crops including vegetables and fruits.";
      case 'red':
      case 'red soil': return "Suitable for millets and pulses. Requires irrigation.";
      case 'sandy': return "Best for melons, coconut, and cactus. Needs frequent watering.";
      case 'cinder soil': return "Usually low in organic matter. Add compost and test nutrients before planting.";
      default: return "Consult an expert for detailed soil health management.";
    }
  }
}
