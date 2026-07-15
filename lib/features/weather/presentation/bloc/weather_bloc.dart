import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_api/features/weather/data/models/weather_forecast_model.dart';
import 'package:weather_api/features/weather/data/services/network_service.dart';

import '../../data/services/location_services.dart';
import '../../data/services/weather_local_storage.dart';
import '../../data/services/weather_service.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc({
    required WeatherService weatherService,
    required LocationServices locationServices,
    required WeatherLocalStorage weatherLocalStorage,
    required NetworkService networkService,
  }) : _weatherService = weatherService,
       _locationServices = locationServices,
       _weatherLocalStorage = weatherLocalStorage,
       _networkService = networkService,
       super(const WeatherInitial()) {
    on<InitializeWeather>(_onInitializeWeather);
    on<FetchCurrentLocationWeather>(_onFetchCurrentLocationWeather);
    on<SearchWeatherByCity>(_onSearchWeatherByCity);
    on<RefreshWeather>(_onRefreshWeather);
  }

  final WeatherService _weatherService;
  final LocationServices _locationServices;
  final WeatherLocalStorage _weatherLocalStorage;
  final NetworkService _networkService;

  Future<void> _onInitializeWeather(
    InitializeWeather event,
    Emitter<WeatherState> emit,
  ) async {
    final cachedWeather = await _weatherLocalStorage.getWeather();

    if (cachedWeather != null) {
      emit(
        WeatherLoaded(
          weatherData: cachedWeather,
          usingCurrentLocation: false,
          lastSearchedCity: cachedWeather.city?.name,
        ),
      );
    } else {
      emit(const WeatherLoading());
    }
    final bool hasInternet = await _networkService.hasInternet;

    if (!hasInternet) {
      if (cachedWeather == null) {
        emit(
          const WeatherFailure(
            errorMessage:
                'No internet connection. Please check your connection.',
          ),
        );
      }

      return;
    }

    try {
      final position = await _locationServices.determineCurrentPosition();

      final latestWeather = await _weatherService.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _weatherLocalStorage.saveWeather(latestWeather);

      emit(
        WeatherLoaded(weatherData: latestWeather, usingCurrentLocation: true),
      );
    } catch (error) {
      debugPrint('Weather initialization error: $error');

      if (cachedWeather == null) {
        emit(
          WeatherFailure(
            errorMessage: _getFriendlyErrorMessage(
              error,
              hasWeatherData: false,
            ),
          ),
        );
      }
    }
  }

  Future<void> _onFetchCurrentLocationWeather(
    FetchCurrentLocationWeather event,
    Emitter<WeatherState> emit,
  ) async {
    final previousWeather = state.weatherData;
    final previousUsingCurrentLocation = state.usingCurrentLocation;
    final previousCity = state.lastSearchedCity;

    emit(
      WeatherLoading(
        weatherData: previousWeather,
        usingCurrentLocation: previousUsingCurrentLocation,
        lastSearchedCity: previousCity,
      ),
    );

    final bool hasInternet = await _checkInternet(
      emit: emit,
      previousWeather: previousWeather,
      previousUsingCurrentLocation: previousUsingCurrentLocation,
      previousCity: previousCity,
    );

    if (!hasInternet) {
      return;
    }

    try {
      final position = await _locationServices.determineCurrentPosition();

      final weatherData = await _weatherService.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _weatherLocalStorage.saveWeather(weatherData);

      emit(WeatherLoaded(weatherData: weatherData, usingCurrentLocation: true));
    } catch (error) {
      debugPrint('Current-location weather error: $error');

      emit(
        WeatherFailure(
          errorMessage: _getFriendlyErrorMessage(
            error,
            hasWeatherData: state.weatherData != null,
          ),
          weatherData: previousWeather,
          usingCurrentLocation: previousUsingCurrentLocation,
          lastSearchedCity: previousCity,
        ),
      );
    }
  }

  Future<void> _onSearchWeatherByCity(
    SearchWeatherByCity event,
    Emitter<WeatherState> emit,
  ) async {
    final String cleanedCity = event.city.trim();

    // Save the current values before changing to WeatherLoading.
    final previousWeather = state.weatherData;
    final previousUsingCurrentLocation = state.usingCurrentLocation;
    final previousCity = state.lastSearchedCity;

    if (cleanedCity.isEmpty) {
      emit(
        WeatherFailure(
          errorMessage: 'Please enter a city name.',
          weatherData: previousWeather,
          usingCurrentLocation: previousUsingCurrentLocation,
          lastSearchedCity: previousCity,
        ),
      );

      return;
    }

    emit(
      WeatherLoading(
        weatherData: previousWeather,
        usingCurrentLocation: previousUsingCurrentLocation,
        lastSearchedCity: previousCity,
      ),
    );

    final bool hasInternet = await _checkInternet(
      emit: emit,
      previousWeather: previousWeather,
      previousUsingCurrentLocation: previousUsingCurrentLocation,
      previousCity: previousCity,
    );

    if (!hasInternet) {
      return;
    }

    try {
      final weatherData = await _weatherService.getWeatherByCity(cleanedCity);

      await _weatherLocalStorage.saveWeather(weatherData);

      emit(
        WeatherLoaded(
          weatherData: weatherData,
          usingCurrentLocation: false,
          lastSearchedCity: cleanedCity,
        ),
      );
    } catch (error) {
      debugPrint('City weather search error: $error');

      emit(
        WeatherFailure(
          errorMessage: _getFriendlyErrorMessage(
            error,
            hasWeatherData: previousWeather != null,
          ),
          weatherData: previousWeather,
          usingCurrentLocation: previousUsingCurrentLocation,
          lastSearchedCity: previousCity,
        ),
      );
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    // Save the currently displayed values before emitting loading.
    final previousWeather = state.weatherData;
    final previousUsingCurrentLocation = state.usingCurrentLocation;
    final previousCity = state.lastSearchedCity;

    emit(
      WeatherLoading(
        weatherData: previousWeather,
        usingCurrentLocation: previousUsingCurrentLocation,
        lastSearchedCity: previousCity,
      ),
    );

    final bool hasInternet = await _checkInternet(
      emit: emit,
      previousWeather: previousWeather,
      previousUsingCurrentLocation: previousUsingCurrentLocation,
      previousCity: previousCity,
    );

    if (!hasInternet) {
      return;
    }

    try {
      if (previousUsingCurrentLocation) {
        final position = await _locationServices.determineCurrentPosition();

        final weatherData = await _weatherService.getWeather(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        await _weatherLocalStorage.saveWeather(weatherData);

        emit(
          WeatherLoaded(weatherData: weatherData, usingCurrentLocation: true),
        );
      } else {
        if (previousCity == null || previousCity.trim().isEmpty) {
          throw Exception('No city available for refresh');
        }

        final weatherData = await _weatherService.getWeatherByCity(
          previousCity,
        );

        await _weatherLocalStorage.saveWeather(weatherData);

        emit(
          WeatherLoaded(
            weatherData: weatherData,
            usingCurrentLocation: false,
            lastSearchedCity: previousCity,
          ),
        );
      }
    } catch (error) {
      debugPrint('Weather refresh error: $error');

      emit(
        WeatherFailure(
          errorMessage: _getFriendlyErrorMessage(
            error,
            hasWeatherData: previousWeather != null,
          ),
          weatherData: previousWeather,
          usingCurrentLocation: previousUsingCurrentLocation,
          lastSearchedCity: previousCity,
        ),
      );
    }
  }

  Future<bool> _checkInternet({
    required Emitter<WeatherState> emit,
    required WeatherForecastModel? previousWeather,
    required bool previousUsingCurrentLocation,
    required String? previousCity,
  }) async {
    final bool hasInternet = await _networkService.hasInternet;

    if (hasInternet) {
      return true;
    }

    emit(
      WeatherFailure(
        errorMessage: previousWeather != null
            ? 'No internet connection. Showing the last saved weather.'
            : 'No internet connection. Please check your connection.',

        weatherData: previousWeather,
        usingCurrentLocation: previousUsingCurrentLocation,
        lastSearchedCity: previousCity,
      ),
    );

    return false;
  }

  String _getFriendlyErrorMessage(
    Object error, {
    required bool hasWeatherData,
  }) {
    final String message = error.toString().toLowerCase();

    bool containsAny(List<String> values) {
      return values.any(message.contains);
    }

    // API request limit.
    if (containsAny([
      '429',
      'too many requests',
      'rate limit',
      'quota exceeded',
    ])) {
      return 'API request limit exceeded. Please try again later.';
    }

    // Invalid API key.
    if (containsAny(['401', 'unauthorized', 'invalid api key'])) {
      return 'Invalid API key. Please check the API configuration.';
    }

    // API subscription or access problem.
    if (containsAny(['403', 'forbidden', 'not subscribed'])) {
      return 'Weather API access is denied. Please check your subscription.';
    }

    // City not found.
    if (containsAny(['404', 'city not found', 'invalid city'])) {
      return 'City not found. Please check the city name.';
    }

    // Weather server problem.
    if (containsAny([
      '500',
      '502',
      '503',
      '504',
      'internal server error',
      'service unavailable',
    ])) {
      return hasWeatherData
          ? 'Weather service is unavailable. Showing the last saved weather.'
          : 'Weather service is temporarily unavailable. Please try again later.';
    }

    // Internet disconnected after the separate internet check.
    if (containsAny([
      'socketexception',
      'failed host lookup',
      'network is unreachable',
      'connection refused',
    ])) {
      return hasWeatherData
          ? 'Internet connection was lost. Showing the last saved weather.'
          : 'Internet connection was lost. Please check your connection.';
    }

    if (containsAny(['timeout', 'timed out'])) {
      return hasWeatherData
          ? 'The request took too long. Showing the last saved weather.'
          : 'The request took too long. Please try again.';
    }

    if (containsAny([
      'location services are disabled',
      'location service is disabled',
    ])) {
      return 'Location services are turned off. Please enable location.';
    }

    if (containsAny(['permanently denied', 'denied forever'])) {
      return 'Location permission is permanently denied. Enable it from app settings.';
    }

    if (message.contains('permission') && message.contains('denied')) {
      return 'Location permission was denied.';
    }

    if (message.contains('no city available for refresh')) {
      return 'Search for a city or use your current location first.';
    }

    return hasWeatherData
        ? 'Unable to update the weather. Showing the last saved weather.'
        : 'Unable to load the weather right now. Please try again.';
  }
}
