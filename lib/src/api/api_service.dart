import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:artiq_flutter/src/models/design.dart';

class ApiService {
  final String baseUrl = 'https://artiq--thompson9395681.replit.app';

  Future<List<Design>> getDesigns(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/designs/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Design.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load designs');
    }
  }

  Future<Design> createDesign(Design design) async {
    final response = await http.post(
      Uri.parse('$baseUrl/designs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(design.toJson()),
    );
    if (response.statusCode == 201) {
      return Design.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create design');
    }
  }

  Future<Design> updateDesign(Design design) async {
    final response = await http.put(
      Uri.parse('$baseUrl/designs/${design.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(design.toJson()),
    );
    if (response.statusCode == 200) {
      return Design.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update design');
    }
  }

  Future<void> deleteDesign(String designId) async {
    final response = await http.delete(Uri.parse('$baseUrl/designs/$designId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete design');
    }
  }
}
