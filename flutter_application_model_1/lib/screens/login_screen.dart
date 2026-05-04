import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  String _verificationId = "";
  bool _isOtpSent = false;
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit phone number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _authService.sendOTP(
      phoneNumber: "+91${_phoneController.text}",
      onCodeSent: (verId) {
        if (!mounted) return;
        setState(() {
          _verificationId = verId;
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification code sent")),
        );
      },
      onVerificationFailed: (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Failed: ${e.message ?? e.code}")),
        );
      },
      onAutoRetrievalTimeout: (verId) {
        if (!mounted || _isOtpSent) return;
        setState(() {
          _verificationId = verId;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP request timed out. Please try again.")),
        );
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final user = await _authService.verifyOTP(
      verificationId: _verificationId,
      smsCode: _otpController.text,
    );

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('phone_number', _phoneController.text);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNav()),
        );
      }
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[800]!, Colors.green[50]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.agriculture, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        "AgroVerse",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(_isOtpSent ? "Verify OTP" : "Join our Community"),
                      const SizedBox(height: 32),

                      if (!_isOtpSent) ...[
                        TextField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            labelText: "User Name",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                            prefixIcon: Icon(Icons.phone),
                            prefixText: "+91 ",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],

                      if (_isOtpSent) ...[
                        const Text(
                          "Enter the 6-digit code sent to your phone",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, letterSpacing: 8),
                          decoration: const InputDecoration(
                            hintText: "000000",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _isOtpSent ? "Verify & Proceed" : "Continue",
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                        ),
                      ),

                      if (_isOtpSent)
                        TextButton(
                          onPressed: () => setState(() => _isOtpSent = false),
                          child: const Text("Change Name or Phone"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
