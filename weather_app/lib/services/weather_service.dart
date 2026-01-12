import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather.dart';

class WeatherService {
  static const String apiKey = '9d8f7032e968b25e7f01a894a061d9b4';
  static const String baseUrl ='https://api.openweathermap.org/data/2.5/weather';

  static Future<Weather> getWeather(String cityName) async {
    try {
      final String url = '$baseUrl?q=$cityName&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        // Makakatulong ito para malaman kung "City not found" (404) o "Invalid API Key" (401)
        throw 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      // I-print ang error sa console para makita mo habang nagde-debug
      print("DEBUG ERROR: $e");
      rethrow;
    }
  }
}
