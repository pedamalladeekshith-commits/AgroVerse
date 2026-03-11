import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://agroverse-1fed.onrender.com';
  static const String _apiKey = 'AGROVERSE_SECRET_TOKEN_2026';
  static const Duration _timeout = Duration(seconds: 10);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  // Helper for standardized GET requests
  static Future<dynamic> _get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection. Please check your data.');
    } on TimeoutException {
      throw Exception('Server took too long to respond.');
    }
  }

  // Helper for standardized POST requests
  static Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('Connection error. Is the backend running?');
    } on TimeoutException {
      throw Exception('Request timed out.');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (contentType.contains('application/json')) {
        return jsonDecode(response.body);
      } else {
        // Successful status but not JSON? Probably a server config issue.
        return response.body;
      }
    } else {
      // Error status code
      if (contentType.contains('application/json')) {
        try {
          final errorData = jsonDecode(response.body);
          final error = errorData['error'] ?? 'Unknown server error';
          throw Exception(error);
        } catch (e) {
          throw Exception('Server returned error ${response.statusCode}');
        }
      } else {
        // HTML or plain text error (like 500 Internal Server Error page)
        throw Exception('Server Error (${response.statusCode}): The request could not be processed.');
      }
    }
  }

  static Future<Map<String, dynamic>> getCurrentWeather({String? city, double? lat, double? lon}) async {
    return await _post('/current_weather', {'city': city, 'lat': lat, 'lon': lon});
  }

  static Future<Map<String, dynamic>> recommendCrop({
    required double n, required double p, required double k, 
    required double ph, required String city, required double landSize,
  }) async {
    return await _post('/recommend_crop', {
      'N': n, 'P': p, 'K': k, 'ph': ph, 'city': city, 'land_size': landSize,
    });
  }

  static Future<Map<String, dynamic>> predictPlantDisease(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict_plant'));
    request.headers['x-api-key'] = _apiKey;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> predictSoil(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict_soil'));
    request.headers['x-api-key'] = _apiKey;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMarketPrices(String commodity, {String? state, String? district, double? farmSize}) async {
    return await _post('/market_prices', {
      'commodity': commodity, 'crop': commodity, 'state': state, 'district': district, 'farm_size': farmSize,
    });
  }

  static Future<List<dynamic>> getSchemes() async => await _get('/schemes');
  static Future<List<dynamic>> getFarmLogs() async => await _get('/farm_logs');
  static Future<void> addFarmLog(Map<String, dynamic> log) async => await _post('/add_farm_log', log);
  static Future<List<dynamic>> getPosts() async => await _get('/posts');
  static Future<void> addPost(String title, String content, String author) async {
    await _post('/add_post', {'title': title, 'content': content, 'author': author});
  }
  static Future<void> addReply(int postId, String content, String author) async {
    await _post('/add_reply', {'post_id': postId, 'content': content, 'author': author});
  }
}
