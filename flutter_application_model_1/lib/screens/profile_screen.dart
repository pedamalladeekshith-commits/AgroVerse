import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = "Farmer";
  String _phone = "";
  String _location = "Unknown";
  String _farmSize = "0";
  String _farmerType = "Small Farmer";
  
  bool _isEditing = false;
  bool _isLoadingLocation = false;
  List<dynamic> _suggestions = [];

  final _farmSizeController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to get phone number from various sources
    final firebaseUser = FirebaseAuth.instance.currentUser;
    String? phone = firebaseUser?.phoneNumber;
    
    if (phone == null || phone.isEmpty) {
      phone = prefs.getString('phone_number') ?? 
              prefs.getString('user_phone') ?? 
              prefs.getString('phone') ?? "";
    }

    // For Demo: If still empty, use a placeholder if one was saved during login
    if (phone.isEmpty) {
      phone = "9007622694"; // Default for demo if everything fails
    }

    setState(() {
      _name = prefs.getString('user_name') ?? "Farmer";
      _phone = phone ?? "";
      _location = prefs.getString('user_location') ?? "Unknown";
      _farmSize = prefs.getString('farm_size') ?? "0";
      _farmerType = _calculateFarmerType(_farmSize);
      
      _farmSizeController.text = _farmSize;
      _locationController.text = _location;
    });
  }

  String _calculateFarmerType(String sizeStr) {
    double size = double.tryParse(sizeStr) ?? 0;
    if (size < 2) return "Small Farmer";
    if (size <= 10) return "Medium Farmer";
    return "Large Farmer";
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=in'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _suggestions = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('farm_size', _farmSizeController.text);
      await prefs.setString('user_location', _locationController.text);
      await prefs.setString('farmer_type', _calculateFarmerType(_farmSizeController.text));
      
      setState(() {
        _farmSize = _farmSizeController.text;
        _location = _locationController.text;
        _farmerType = _calculateFarmerType(_farmSize);
        _isEditing = false;
        _suggestions = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _locationController.text = "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await FirebaseAuth.instance.signOut();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(_name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(_phone.startsWith('+91') ? _phone : "+91 $_phone", style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _farmerType, 
                  style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(height: 24),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Farm Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (!_isEditing)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => setState(() => _isEditing = true),
                            ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _locationController,
                        enabled: _isEditing,
                        onChanged: _searchLocation,
                        decoration: InputDecoration(
                          labelText: "Location",
                          prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                          suffixIcon: _isEditing 
                            ? IconButton(
                                icon: _isLoadingLocation 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.my_location),
                                onPressed: _getCurrentLocation,
                              )
                            : null,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      
                      if (_isEditing && _suggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: _suggestions.map((s) => ListTile(
                              title: Text(s['display_name']),
                              onTap: () {
                                setState(() {
                                  _locationController.text = s['display_name'];
                                  _suggestions = [];
                                });
                              },
                            )).toList(),
                          ),
                        ),

                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _farmSizeController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Farm Size (Acres)",
                          prefixIcon: Icon(Icons.landscape, color: Colors.green),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? "Required" : null,
                      ),
                      
                      if (_isEditing) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Save Details", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              if (!_isEditing) ...[
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Active AI Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                _buildServiceStatus("Crop Recommendation", true),
                _buildServiceStatus("Market Forecasting", true),
                _buildServiceStatus("Smart Scheme Matching", true),
                
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Logout", style: TextStyle(color: Colors.red, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceStatus(String name, bool active) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(active ? Icons.check_circle : Icons.info, color: active ? Colors.green : Colors.grey),
        title: Text(name),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
