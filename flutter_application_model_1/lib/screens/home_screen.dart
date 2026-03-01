import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';
import 'crop_recommendation_screen.dart';
import 'pest_disease_detection_screen.dart';
import 'marketplace_screen.dart';
import 'government_schemes_screen.dart';
import 'weather_climate_screen.dart';
import 'learning_videos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroVers"),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // TODO: Implement language selection
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CropRecommendationScreen(),
                  ),
                );
              },
              child: const FeatureCard(
                title: "Crop Recommendation",
                icon: Icons.eco,
                color: Colors.green,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeatherClimateScreen(),
                  ),
                );
              },
              child: const FeatureCard(
                title: "Weather & Climate",
                icon: Icons.cloud,
                color: Colors.blue,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PestDiseaseDetectionScreen(),
                  ),
                );
              },
              child: const FeatureCard(
                title: "Pest & Disease",
                icon: Icons.bug_report,
                color: Colors.red,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GovernmentSchemesScreen(),
                  ),
                );
              },
              child: const FeatureCard(
                title: "Government Schemes",
                icon: Icons.account_balance,
                color: Colors.orange,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketplaceScreen(),
                  ),
                );
              },
              child: const FeatureCard(
                title: "Marketplace",
                icon: Icons.shopping_cart,
                color: Colors.purple,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LearningVideosScreen(),
                  ),
                );
              },
              child: const FeatureCard(
                title: "Learning Videos",
                icon: Icons.play_circle,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
