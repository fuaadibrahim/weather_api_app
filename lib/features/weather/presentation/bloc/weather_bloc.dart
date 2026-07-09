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
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final cachedWeather = await _weatherLocalStorage.getWeather();

      if (cachedWeather != null) {
        emit(
          state.copyWith(
            weatherData: cachedWeather,
            isLoading: false,
            clearErrorMessage: true,
            usingCurrentLocation: false,
            lastSearchedCity: cachedWeather.city?.name,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, clearErrorMessage: true));
      }
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load saved weather',
        ),
      );
    }
  }

  Future<void> _onFetchCurrentLocationWeather(
    FetchCurrentLocationWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

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
          clearErrorMessage: true,
          usingCurrentLocation: true,
          clearLastSearchedCity: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onSearchWeatherByCity(
    SearchWeatherByCity event,
    Emitter<WeatherState> emit,
  ) async {
    final String cleanedCity = event.city.trim();

    if (cleanedCity.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter a city name'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final weatherData = await _weatherService.getWeatherByCity(cleanedCity);

      await _weatherLocalStorage.saveWeather(weatherData);

      emit(
        state.copyWith(
          weatherData: weatherData,
          isLoading: false,
          clearErrorMessage: true,
          usingCurrentLocation: false,
          lastSearchedCity: cleanedCity,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

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
        final city = state.lastSearchedCity;

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
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
