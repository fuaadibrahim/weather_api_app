import '../../data/models/weather_forecast_model.dart';

class WeatherState {
  const WeatherState({
    this.weatherData,
    this.isLoading = false,
    this.errorMessage,
    this.usingCurrentLocation = false,
    this.lastSearchedCity,
    this.isInitialized = false,
  });

  final WeatherForecastModel? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final bool usingCurrentLocation;
  final String? lastSearchedCity;
  final bool isInitialized;

  WeatherState copyWith({
    WeatherForecastModel? weatherData,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? usingCurrentLocation,
    String? lastSearchedCity,
    bool clearLastSearchedCity = false,
    bool? isInitialized,
  }) {
    return WeatherState(
      weatherData: weatherData ?? this.weatherData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      usingCurrentLocation: usingCurrentLocation ?? this.usingCurrentLocation,
      lastSearchedCity: clearLastSearchedCity
          ? null
          : lastSearchedCity ?? this.lastSearchedCity,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
