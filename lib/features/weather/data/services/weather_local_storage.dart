import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/weather_forecast_model.dart';

class WeatherLocalStorage {
  WeatherLocalStorage(this._box);

  final Box<dynamic> _box;

  static const String _weatherDataKey = 'weatherData';

  Future<void> saveWeather(WeatherForecastModel weatherData) async {
    final String encodedWeather = jsonEncode(weatherData.toJson());

    await _box.put(_weatherDataKey, encodedWeather);

  
  }

  Future<WeatherForecastModel?> getWeather() async {
    final cachedData = _box.get(_weatherDataKey);

    

    if (cachedData == null) {
      return null;
    }

    try {
      final Map<String, dynamic> weatherMap;

      if (cachedData is String) {
        weatherMap = Map<String, dynamic>.from(jsonDecode(cachedData));
      } else if (cachedData is Map) {
        weatherMap = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(cachedData)),
        );
      } else {
      
        return null;
      }

      final WeatherForecastModel weatherData =
          WeatherForecastModel.fromJson(weatherMap);

      

      return weatherData;
    } catch (error) {
      
      return null;
    }
  }

  Future<void> clearWeather() async {
    await _box.delete(_weatherDataKey);
  }
}