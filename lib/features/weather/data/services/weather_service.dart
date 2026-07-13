import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_forecast_model.dart';

class CityCoordinates {
  final double latitude;
  final double longitude;

  const CityCoordinates({required this.latitude, required this.longitude});
}

class WeatherService {
  static const String _host = 'open-weather13.p.rapidapi.com';

  // Paste your newly rotated RapidAPI key here.
  static const String _apiKey =
      '7a0716810emsh3de077da3551710p198a3bjsn7438bd3e83cb';

  Map<String, String> get _headers {
    return {'X-RapidAPI-Key': _apiKey.trim(), 'X-RapidAPI-Host': _host};
  }

  Future<CityCoordinates> getCoordinatesByCity(String city) async {
    final cleanedCity = city.trim();

    if (cleanedCity.isEmpty) {
      throw Exception('Please enter a city name');
    }

    // Correct city endpoint:
    // https://open-weather13.p.rapidapi.com/city?city=Kozhikode&lang=EN
    final url = Uri.https(_host, '/city', {'city': cleanedCity, 'lang': 'EN'});

    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'City request failed: '
          '${response.statusCode}\n'
          '${_getErrorMessage(response)}',
        );
      }

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        throw Exception('Invalid city response format');
      }

      final dynamic coordinatesData = decodedData['coord'];

      if (coordinatesData is! Map<String, dynamic>) {
        throw Exception('Coordinates were not found for $cleanedCity');
      }

      final double? latitude = (coordinatesData['lat'] as num?)?.toDouble();

      final double? longitude = (coordinatesData['lon'] as num?)?.toDouble();

      if (latitude == null || longitude == null) {
        throw Exception('Coordinates were not found for $cleanedCity');
      }

      return CityCoordinates(latitude: latitude, longitude: longitude);
    } on TimeoutException {
      throw Exception('City request timed out. Please try again.');
    } on FormatException {
      throw Exception('The city API returned invalid data.');
    }
  }

  Future<WeatherForecastModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.https(_host, '/fivedaysforcast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'lang': 'EN',
    });

    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Forecast request failed: '
          '${response.statusCode}\n'
          '${_getErrorMessage(response)}',
        );
      }

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        throw Exception('Invalid forecast response format');
      }

      return WeatherForecastModel.fromJson(decodedData);
    } on TimeoutException {
      throw Exception('Forecast request timed out. Please try again.');
    } on FormatException {
      throw Exception('The forecast API returned invalid data.');
    }
  }

  Future<WeatherForecastModel> getWeatherByCity(String city) async {
    final coordinates = await getCoordinatesByCity(city);

    return getWeather(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    );
  }

  String _getErrorMessage(http.Response response) {
    try {
      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is Map<String, dynamic>) {
        final message = decodedData['message']?.toString();

        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Response was not valid JSON.
    }

    return 'Request failed with status '
        '${response.statusCode}';
  }
}
