import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/location_services.dart';
import '../../data/services/weather_service.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc({
    required WeatherService weatherService,
    required LocationServices locationServices,
  }) : _weatherService = weatherService,
       _locationServices = locationServices,
       super(const WeatherState()) {
    on<FetchCurrentLocationWeather>(_onFetchCurrentLocationWeather);

    on<SearchWeatherByCity>(_onSearchWeatherByCity);

    on<RefreshWeather>(_onRefreshWeather);
  }

  final WeatherService _weatherService;
  final LocationServices _locationServices;

  Future<void> _onFetchCurrentLocationWeather(
    FetchCurrentLocationWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final position = await _locationServices.determineCurrentPosition();

      final weatherData = await _weatherService.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      emit(
        state.copyWith(
          weatherData: weatherData,
          isLoading: false,
          usingCurrentLocation: true,
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

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final weatherData = await _weatherService.getWeatherByCity(cleanedCity);

      emit(
        state.copyWith(
          weatherData: weatherData,
          isLoading: false,
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
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      if (state.usingCurrentLocation) {
        final position = await _locationServices.determineCurrentPosition();

        final weatherData = await _weatherService.getWeather(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        emit(
          state.copyWith(
            weatherData: weatherData,
            isLoading: false,
            usingCurrentLocation: true,
          ),
        );
      } else {
        final city = state.lastSearchedCity;

        if (city == null || city.trim().isEmpty) {
          throw Exception('No city available for refresh');
        }

        final weatherData = await _weatherService.getWeatherByCity(city);

        emit(
          state.copyWith(
            weatherData: weatherData,
            isLoading: false,
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
