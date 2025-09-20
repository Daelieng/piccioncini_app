import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/wifi_constants.dart';
import '../models/server_models.dart';

class ApiService {
  static Future<bool> updateDeviceEmotion(String emotion, String color) async {
    try {
      final request = EmotionUpdateRequest(
        emotion: emotion,
        color: color,
      );

      final url = '${WiFiConstants.BASE_URL}${WiFiConstants.putDeviceAppEndpoint}';
      print('📤 PUT $url');
      print('📤 Payload: ${jsonEncode(request.toJson())}');

      final response = await http.put(
        Uri.parse(url),
        headers: WiFiConstants.DEFAULT_HEADERS,
        body: jsonEncode(request.toJson()),
      ).timeout(WiFiConstants.REQUEST_TIMEOUT);

      print('📥 Response: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('📥 Body: ${response.body}');
        return true;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception updating emotion: $e');
      return false;
    }
  }

  static Future<DeviceAppStatus?> getDeviceAppStatus() async {
    try {
      final url = '${WiFiConstants.BASE_URL}${WiFiConstants.getDeviceAppEndpoint}';
      print('📡 GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: WiFiConstants.DEFAULT_HEADERS,
      ).timeout(WiFiConstants.REQUEST_TIMEOUT);

      print('📥 Status response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('📥 Data: $data');
        DeviceAppStatus data_returned = DeviceAppStatus.fromJson(data);
        print(data_returned);
        return data_returned;
      } else {
        print('❌ Status API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception getting status: $e');
      return null;
    }
  }
}