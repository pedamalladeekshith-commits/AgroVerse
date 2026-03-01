import 'package:flutter/material.dart';

class GovernmentSchemesScreen extends StatelessWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Government Schemes"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("PM Kisan Samman Nidhi"),
              subtitle: const Text("₹6000 per year for eligible farmers"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Apply Now"),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("Kisan Credit Card"),
              subtitle: const Text("Short-term formal credit to farmers"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Apply Now"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
