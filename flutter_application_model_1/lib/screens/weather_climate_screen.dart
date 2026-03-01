import 'package:flutter/material.dart';

class WeatherClimateScreen extends StatelessWidget {
  const WeatherClimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather & Climate"),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_queue, size: 80, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                "Weather and Climate information will be displayed here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Future integration with weather APIs to provide real-time updates and forecasts.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
