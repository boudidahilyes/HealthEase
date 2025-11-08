import 'dart:convert';
import 'package:healthease/core/dto/prescription_dto.dart';
import 'package:http/http.dart' as http;

class PrescriptionService {
  static const String _baseUrl = 'http://localhost:5141/api/Prescription';

  Future<PrescriptionDto> createPrescription(PrescriptionDto prescription) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(prescription.toMap()),
    );

    if (response.statusCode == 200) {
      return PrescriptionDto.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create prescription: ${response.statusCode}');
    }
  }

  Future<PrescriptionDto> getPrescriptionById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return PrescriptionDto.fromMap(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Prescription not found');
    } else {
      throw Exception('Failed to load prescription: ${response.statusCode}');
    }
  }

  Future<List<PrescriptionDto>> getPrescriptionsByPatient(int patientId) async {
    final response = await http.get(Uri.parse('$_baseUrl/patient/$patientId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PrescriptionDto.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load patient prescriptions: ${response.statusCode}');
    }
  }

  Future<List<PrescriptionDto>> getPrescriptionsByDoctor(int doctorId) async {
    final response = await http.get(Uri.parse('$_baseUrl/doctor/$doctorId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PrescriptionDto.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load doctor prescriptions: ${response.statusCode}');
    }
  }
}