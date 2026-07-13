import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  }) : _weatherService = weatherService,
       _locationServices = locationServices,
       _weatherLocalStorage = weatherLocalStorage,
       super(const WeatherState()) {
    on<InitializeWeather>(_onInitializeWeather);
    on<FetchCurrentLocationWeather>(_onFetchCurrentLocationWeather);
    on<SearchWeatherByCity>(_onSearchWeatherByCity);
    on<RefreshWeather>(_onRefreshWeather);
  }

  final WeatherService _weatherService;
  final LocationServices _locationServices;
  final WeatherLocalStorage _weatherLocalStorage;

  Future<void> _onInitializeWeather(
    InitializeWeather event,
    Emitter<WeatherState> emit,
  ) async {
    final cachedWeather = await _weatherLocalStorage.getWeather();

    if (cachedWeather != null) {
      emit(
        state.copyWith(
          weatherData: cachedWeather,
          isLoading: false,
          isInitialized: true,
          usingCurrentLocation: false,
          lastSearchedCity: cachedWeather.city?.name,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          weatherData: null,
          isLoading: false,
          isInitialized: true,
          clearErrorMessage: true,
        ),
      );
    }

    try {
      final position = await _locationServices.determineCurrentPosition();

      final latestWeather = await _weatherService.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _weatherLocalStorage.saveWeather(latestWeather);

      emit(
        state.copyWith(
          weatherData: latestWeather,
          isLoading: false,
          isInitialized: true,
          usingCurrentLocation: true,
          clearLastSearchedCity: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      debugPrint('Weather initialization error: $error');

      if (cachedWeather == null) {
        emit(
          state.copyWith(
            weatherData: null,
            isLoading: false,
            isInitialized: true,
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
    emit(
      state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final position = await _locationServices.determineCurrentPosition();

      final weatherData = await _weatherService.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _weatherLocalStorage.saveWeather(weatherData);

      emit(
        state.copyWith(
          weatherData: weatherData,
          isLoading: false,
          isInitialized: true,
          clearErrorMessage: true,
          usingCurrentLocation: true,
          clearLastSearchedCity: true,
        ),
      );
    } catch (error) {
      debugPrint('Current-location weather error: $error');

      emit(
        state.copyWith(
          isLoading: false,
          isInitialized: true,
          errorMessage: _getFriendlyErrorMessage(
            error,
            hasWeatherData: state.weatherData != null,
          ),
        ),
      );
    }
  }

  Future<void> _onSearchWeatherByCity(
    SearchWeatherByCity event,
    Emitter<WeatherState> emit,
  ) async {
    final String cleanedCity = event.city.trim();

    if (cleanedCity.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please enter a city name.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final weatherData = await _weatherService.getWeatherByCity(cleanedCity);

      await _weatherLocalStorage.saveWeather(weatherData);

      emit(
        state.copyWith(
          weatherData: weatherData,
          isLoading: false,
          isInitialized: true,
          clearErrorMessage: true,
          usingCurrentLocation: false,
          lastSearchedCity: cleanedCity,
        ),
      );
    } catch (error) {
      debugPrint('City weather search error: $error');

      emit(
        state.copyWith(
          isLoading: false,
          isInitialized: true,
          errorMessage: _getFriendlyErrorMessage(
            error,
            hasWeatherData: state.weatherData != null,
          ),
        ),
      );
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
      ),
    );

    try {
      if (state.usingCurrentLocation) {
        final position = await _locationServices.determineCurrentPosition();

        final weatherData = await _weatherService.getWeather(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        await _weatherLocalStorage.saveWeather(weatherData);

        emit(
          state.copyWith(
            weatherData: weatherData,
            isLoading: false,
            clearErrorMessage: true,
            usingCurrentLocation: true,
            clearLastSearchedCity: true,
          ),
        );
      } else {
        final String? city = state.lastSearchedCity;

        if (city == null || city.trim().isEmpty) {
          throw Exception('No city available for refresh');
        }

        final weatherData = await _weatherService.getWeatherByCity(city);

        await _weatherLocalStorage.saveWeather(weatherData);

        emit(
          state.copyWith(
            weatherData: weatherData,
            isLoading: false,
            clearErrorMessage: true,
            usingCurrentLocation: false,
            lastSearchedCity: city,
          ),
        );
      }
    } catch (error) {
      debugPrint('Weather refresh error: $error');

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _getFriendlyErrorMessage(
            error,
            hasWeatherData: state.weatherData != null,
          ),
        ),
      );
    }
  }

  String _getFriendlyErrorMessage(
    Object error, {
    required bool hasWeatherData,
  }) {
    final String message = error.toString().toLowerCase();

    if (message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated with hostname') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused')) {
      if (hasWeatherData) {
        return 'No internet connection. Showing the last saved weather.';
      }

      return 'No internet connection. Please check your connection.';
    }

    if (message.contains('timeout') ||
        message.contains('timed out')) {
      if (hasWeatherData) {
        return 'The request took too long. Showing the last saved weather.';
      }

      return 'The request took too long. Please try again.';
    }

    if (message.contains('location services are disabled') ||
        message.contains('location service is disabled')) {
      return 'Location services are turned off. Please enable location.';
    }

    if (message.contains('permanently denied') ||
        message.contains('denied forever')) {
      return 'Location permission is permanently denied. Enable it from app settings.';
    }

    if (message.contains('permission') &&
        message.contains('denied')) {
      return 'Location permission was denied.';
    }

    if (message.contains('city not found') ||
        message.contains('invalid city') ||
        message.contains('404')) {
      return 'City not found. Please check the city name.';
    }

    if (message.contains('no city available for refresh')) {
      return 'Search for a city or use your current location first.';
    }

    if (message.contains('401') ||
        message.contains('403') ||
        message.contains('unauthorized') ||
        message.contains('forbidden')) {
      return 'Weather service access failed. Please check the API configuration.';
    }

    if (hasWeatherData) {
      return 'Unable to update the weather. Showing the last saved weather.';
    }

    return 'Unable to load the weather right now. Please try again.';
  }
}