import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopScreen extends StatefulWidget {
  final String? product;
  const ShopScreen({super.key, this.product});

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<Map<String, String>> _categories = [
    {
      "title": "Seeds",
      "icon": "🌱",
      "url": "https://www.bighaat.com/collections/seeds",
      "description": "High-quality seeds for various crops"
    },
    {
      "title": "Fertilizers",
      "icon": "🧪",
      "url": "https://www.bighaat.com/collections/fertilizers",
      "description": "Essential nutrients for your soil"
    },
    {
      "title": "Pesticides",
      "icon": "🛡️",
      "url": "https://www.bighaat.com/collections/pesticides",
      "description": "Protect your crops from pests and diseases"
    },
    {
      "title": "Farming Tools",
      "icon": "🚜",
      "url": "https://www.bighaat.com/collections/agriculture-tools",
      "description": "Modern tools for efficient farming"
    },
  ];

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }

  void _searchProduct(String product) {
    _launchUrl("https://www.bighaat.com/search?q=$product");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroVerse Shop"),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          if (widget.product != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange[50],
              child: Column(
                children: [
                  Text(
                    "Recommended for you:",
                    style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _searchProduct(widget.product!),
                    icon: const Icon(Icons.shopping_cart),
                    label: Text("Buy ${widget.product}"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () => _launchUrl(category['url']!),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(category['icon']!, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          category['title']!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            category['description']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Powered by BigHaat",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
