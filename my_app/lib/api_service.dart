import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://reqres.in/api/users'; // Replace with your API URL

  static Future<String> sendDataToApi(String qrCodeData) async {
    final response = await http.post(
      Uri.parse('$apiUrl/send-data'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'qrCodeData': qrCodeData}),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      return 'failed';
    }
  }
}
