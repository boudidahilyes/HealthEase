import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MedicineService {
  late final String _baseUrl;

  MedicineService() {
    if (kIsWeb) {
      _baseUrl = 'http://localhost:5141/api/Medicine';
    } else {
      _baseUrl = 'http://192.168.100.225:5141/api/Medicine';
    }
  }

  Future<void> decrementRemaining(int medicineId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/decrement/$medicineId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Successfully decremented remaining.');
    } else if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception('Failed to decrement: ${data['message']}');
    } else {
      throw Exception('Failed to decrement remaining: ${response.statusCode}');
    }
  }
}
