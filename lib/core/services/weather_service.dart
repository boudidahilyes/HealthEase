import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = '1d0b9df54dbe9c8ed6d4f65b59fd7afa';
  static const String city = 'Tunis';

  static Future<Map<String, dynamic>?> getWeatherForecast(DateTime appointmentDate) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$city&exclude=hourly,minutely&appid=$apiKey&units=metric'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _findForecastForDate(data, appointmentDate);
      } else {
        print('Weather API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Weather API exception: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _findForecastForDate(Map<String, dynamic> data, DateTime targetDate) {
    final List<dynamic> forecasts = data['list'];

    for (var forecast in forecasts) {
      final forecastDate = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);

      if (forecastDate.year == targetDate.year &&
          forecastDate.month == targetDate.month &&
          forecastDate.day == targetDate.day) {
        return forecast;
      }
    }

    for (var forecast in forecasts) {
      final forecastDate = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      if (forecastDate.day == targetDate.day) {
        return forecast;
      }
    }

    return null;
  }

  static String getWeatherSuggestion(Map<String, dynamic>? weatherData, String speciality, DateTime appointmentDate) {
    if (weatherData == null) {
      return '🌤️ Check weather conditions for ${_formatAppointmentDate(appointmentDate)}';
    }

    try {
      final weather = weatherData['weather'][0];
      final main = weather['main'];
      final temp = weatherData['main']['temp'];

      String datePrefix = _formatAppointmentDate(appointmentDate);

      if (main == 'Rain' || main == 'Drizzle') {
        return '$datePrefix 🌧️ Rain expected - Bring umbrella';
      } else if (main == 'Snow') {
        return '$datePrefix ❄️ Snow forecast - Dress warmly';
      } else if (temp > 30) {
        return '$datePrefix 🔥 Hot day - Stay hydrated';
      } else if (temp < 5) {
        return '$datePrefix 🥶 Cold weather - Bundle up';
      } else if (main == 'Extreme') {
        return '$datePrefix ⚠️ Severe weather - Travel carefully';
      }

      return '$datePrefix 🌤️ Good weather for your appointment';

    } catch (e) {
      return '🌤️ Check weather for ${_formatAppointmentDate(appointmentDate)}';
    }
  }

  static String _formatAppointmentDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(date.year, date.month, date.day);

    final difference = appointmentDay.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == 2) return 'In 2 days';
    if (difference < 7) return 'In $difference days';

    return 'On ${date.day}/${date.month}';
  }
}