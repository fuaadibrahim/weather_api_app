import 'package:weather_api/features/weather/data/models/weather_forecast_model.dart';

class WeatherState {
  const WeatherState({
    this.weatherData,
    this.isLoading = false,
    this.errorMessage,
    this.usingCurrentLocation = true,
    this.lastSearchedCity,
  });

  final WeatherForecastModel? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final bool usingCurrentLocation;
  final String? lastSearchedCity;

  WeatherState copyWith({
    WeatherForecastModel? weatherData,
    bool? isLoading,
    String? errorMessage,
    bool? usingCurrentLocation,
    String? lastSearchedCity,
  }) {
    return WeatherState(
      weatherData: weatherData ?? this.weatherData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      usingCurrentLocation: usingCurrentLocation ?? this.usingCurrentLocation,
      lastSearchedCity: lastSearchedCity ?? this.lastSearchedCity,
    );
  }
}
