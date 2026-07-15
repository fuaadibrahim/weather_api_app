import '../../data/models/weather_forecast_model.dart';

sealed class WeatherState {
  const WeatherState();

  WeatherForecastModel? get weatherData => null;

  bool get isLoading => false;

  String? get errorMessage => null;

  bool get usingCurrentLocation => false;

  String? get lastSearchedCity => null;
}

final class WeatherInitial extends WeatherState {
  const WeatherInitial();

  @override
  bool get isLoading => true;
}

final class WeatherEmpty extends WeatherState {
  const WeatherEmpty();
}

final class WeatherLoading extends WeatherState {
  @override
  final WeatherForecastModel? weatherData;

  @override
  final bool usingCurrentLocation;

  @override
  final String? lastSearchedCity;

  const WeatherLoading({
    this.weatherData,
    this.usingCurrentLocation = false,
    this.lastSearchedCity,
  });

  @override
  bool get isLoading => true;
}

final class WeatherLoaded extends WeatherState {
  @override
  final WeatherForecastModel weatherData;

  @override
  final bool usingCurrentLocation;

  @override
  final String? lastSearchedCity;

  const WeatherLoaded({
    required this.weatherData,
    required this.usingCurrentLocation,
    this.lastSearchedCity,
  });
}

final class WeatherFailure extends WeatherState {
  @override
  final String errorMessage;

  @override
  final WeatherForecastModel? weatherData;

  @override
  final bool usingCurrentLocation;

  @override
  final String? lastSearchedCity;

  const WeatherFailure({
    required this.errorMessage,
    this.weatherData,
    this.usingCurrentLocation = false,
    this.lastSearchedCity,
  });
}
