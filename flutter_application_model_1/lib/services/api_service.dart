import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.resolvedApiBaseUrl;
  static String get _apiKey => AppConfig.apiKey;
  static const Duration _timeout = Duration(seconds: 120);
  static const Duration _multipartTimeout = Duration(seconds: 180);
  
  // For debugging request counts
  static int _requestCount = 0;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  // Helper for standardized GET requests
  static Future<dynamic> _get(String endpoint) async {
    _requestCount++;
    final requestId = _requestCount;
    if (kDebugMode) {
      print("[ApiService] #$requestId Calling (GET): $baseUrl$endpoint");
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(_timeout);
      
      if (kDebugMode) {
        print("[ApiService] #$requestId Response: ${response.statusCode}");
      }
      return _handleResponse(response);
    } on SocketException catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId SocketException: $e");
      throw Exception('No Internet connection. Please check your data.');
    } on TimeoutException {
      if (kDebugMode) print("[ApiService] #$requestId TimeoutException for GET $endpoint");
      throw Exception('Server took too long to respond.');
    } catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId Unknown error: $e");
      rethrow;
    }
  }

  // Helper for standardized POST requests
  static Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    _requestCount++;
    final requestId = _requestCount;
    if (kDebugMode) {
      print("[ApiService] #$requestId Calling (POST): $baseUrl$endpoint");
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(_timeout);
      
      if (kDebugMode) {
        print("[ApiService] #$requestId Response: ${response.statusCode}");
      }
      return _handleResponse(response);
    } on SocketException catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId SocketException: $e");
      throw Exception('Connection error. Check your API base URL or backend status.');
    } on TimeoutException {
      if (kDebugMode) print("[ApiService] #$requestId TimeoutException for POST $endpoint");
      throw Exception('Request timed out.');
    } catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId Unknown error: $e");
      rethrow;
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (contentType.contains('application/json')) {
        return jsonDecode(response.body);
      } else {
        return response.body;
      }
    } else {
      if (contentType.contains('application/json')) {
        final errorData = jsonDecode(response.body);
        final error = errorData['message'] ?? errorData['error'] ?? 'Unknown server error';
        throw Exception(error);
      } else {
        throw Exception('Server Error (${response.statusCode}): The request could not be processed.');
      }
    }
  }

  static String _formatConfidence(dynamic value) {
    if (value == null) return '0%';
    if (value is String) return value.contains('%') ? value : '$value%';
    if (value is num) {
      final percent = value <= 1 ? value * 100 : value;
      return '${percent.toStringAsFixed(1)}%';
    }
    return value.toString();
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
    _requestCount++;
    final requestId = _requestCount;
    if (kDebugMode) print("[ApiService] #$requestId Calling (Multipart): $baseUrl/predict_plant");

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict_plant'));
      request.headers['x-api-key'] = _apiKey;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send().timeout(_multipartTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      final result = Map<String, dynamic>.from(_handleResponse(response));
      result['confidence'] = _formatConfidence(result['confidence']);
      return result;
    } on SocketException catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId SocketException (Multipart): $e");
      throw Exception('Connection error while uploading image. Please check your internet and backend status.');
    } on TimeoutException {
      if (kDebugMode) print("[ApiService] #$requestId TimeoutException for multipart /predict_plant");
      throw Exception('Disease detection took too long. The server may be waking up or under heavy load. Please try again.');
    } catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId Unknown multipart error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> predictSoil(File imageFile) async {
    _requestCount++;
    final requestId = _requestCount;
    if (kDebugMode) print("[ApiService] #$requestId Calling (Multipart): $baseUrl/predict_soil");

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict_soil'));
      request.headers['x-api-key'] = _apiKey;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send().timeout(_multipartTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      final result = Map<String, dynamic>.from(_handleResponse(response));
      result['confidence'] = _formatConfidence(result['confidence']);
      return result;
    } on SocketException catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId SocketException (Multipart): $e");
      throw Exception('Connection error while uploading image. Please check your internet and backend status.');
    } on TimeoutException {
      if (kDebugMode) print("[ApiService] #$requestId TimeoutException for multipart /predict_soil");
      throw Exception('Soil analysis took too long. The server may be waking up or loading the AI model. Please try again.');
    } catch (e) {
      if (kDebugMode) print("[ApiService] #$requestId Unknown multipart error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMarketPrices(String commodity, {String? state, String? district, double? farmSize}) async {
    return await _post('/market_prices', {
      'commodity': commodity,
      'crop': commodity,
      'state': state,
      'district': district,
      'farm_size': farmSize,
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
