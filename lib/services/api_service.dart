import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Send message to backend
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get cyber crime statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get statistics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Submit complaint
  static Future<Map<String, dynamic>> submitComplaint(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/complaints'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit complaint');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}