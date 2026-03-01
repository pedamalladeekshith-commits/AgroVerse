import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PestDiseaseDetectionScreen extends StatefulWidget {
  const PestDiseaseDetectionScreen({super.key});

  @override
  _PestDiseaseDetectionScreenState createState() =>
      _PestDiseaseDetectionScreenState();
}

class _PestDiseaseDetectionScreenState
    extends State<PestDiseaseDetectionScreen> {
  File? _image;
  final picker = ImagePicker();
  String? _diseaseName;
  double? _confidence;
  bool _loading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _predict();
    }
  }

  Future<void> _predict() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://YOUR_IP_ADDRESS:5000/predict'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', _image!.path),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final decoded = json.decode(respStr);
        setState(() {
          _diseaseName = decoded['disease'];
          _confidence = decoded['confidence'];
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
        title: const Text("Pest & Disease Detection"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.cover)
                  : const Center(
                      child: Text("Camera Preview / Selected Image"),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement camera logic
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Upload from Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else if (_diseaseName != null)
              Card(
                child: ListTile(
                  title: Text("Disease Name: $_diseaseName"),
                  subtitle: Text("Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%"),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Immediate Action Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "- Apply fungicide.\n- Remove infected leaves.\n- Ensure proper irrigation.",
            ),
          ],
        ),
      ),
    );
  }
}
