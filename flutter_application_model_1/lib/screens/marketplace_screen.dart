import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buying & Selling"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Seeds & Fertilizers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text("Urea Fertilizer"),
              subtitle: const Text("₹500 per bag"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Call Seller"),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Fresh Produce",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text("Tomatoes"),
              subtitle: const Text("₹20 per kg"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Call Seller"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
