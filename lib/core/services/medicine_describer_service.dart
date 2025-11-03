import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MedicineDescriberService {
  Future<String> describeMedicine(File imageFile) async {
    final url = Uri.parse('http://10.83.70.178:8090/api/medicine_description');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return data['description'] ?? 'No description returned';
    } else {
      throw Exception(
        'Failed to get medicine description (status: ${response.statusCode})',
      );
    }
  }
}
