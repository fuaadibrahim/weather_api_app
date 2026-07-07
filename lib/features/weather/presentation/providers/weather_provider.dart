// import 'package:flutter/foundation.dart';

// import '../../data/models/weather_forecast_model.dart';
// import '../../data/services/location_services.dart';
// import '../../data/services/weather_service.dart';

// class WeatherProvider extends ChangeNotifier {
//   WeatherProvider({
//     required WeatherService weatherService,
//     required LocationServices locationServices,
//   }) : _weatherService = weatherService,
//        _locationServices = locationServices;

//   final WeatherService _weatherService;
//   final LocationServices _locationServices;

//   WeatherForecastModel? _weatherData;
//   bool _isLoading = false;
//   String? _errorMessage;

//   bool _usingCurrentLocation = true;
//   String? _lastSearchedCity;

//   WeatherForecastModel? get weatherData => _weatherData;

//   bool get isLoading => _isLoading;

//   String? get errorMessage => _errorMessage;

//   bool get usingCurrentLocation => _usingCurrentLocation;

//   String? get lastSearchedCity => _lastSearchedCity;

//   bool get hasWeatherData => _weatherData != null;

//   String? get detectedCityName {
//     final String? cityName = _weatherData?.city?.name?.trim();

//     if (cityName == null || cityName.isEmpty) {
//       return null;
//     }

//     return cityName;
//   }

//   Future<bool> fetchWeatherFromCurrentLocation() async {
//     if (_isLoading) {
//       return false;
//     }

//     setLoading(true);

//     try {
//       final position = await _locationServices.determineCurrentPosition();

//       final WeatherForecastModel result = await _weatherService.getWeather(
//         latitude: position.latitude,
//         longitude: position.longitude,
//       );

//       _weatherData = result;
//       _usingCurrentLocation = true;
//       _lastSearchedCity = null;

//       return true;
//     } catch (error) {
//       _errorMessage = _convertErrorToMessage(error);
//       return false;
//     } finally {
//       setLoading(false);
//     }
//   }

//   Future<bool> fetchWeatherByCity(String city) async {
//     final String cleanedCity = city.trim();

//     if (cleanedCity.isEmpty) {
//       _errorMessage = 'Please enter city name';
//       notifyListeners();
//       return false;
//     }

//     if (_isLoading) {
//       return false;
//     }

//     setLoading(true);

//     try {
//       final WeatherForecastModel result = await _weatherService
//           .getWeatherByCity(cleanedCity);

//       _weatherData = result;
//       _usingCurrentLocation = false;
//       _lastSearchedCity = cleanedCity;

//       return true;
//     } catch (error) {
//       _errorMessage = _convertErrorToMessage(error);
//       return false;
//     } finally {
//       setLoading(false);
//     }
//   }

//   Future<bool> refreshWeather() async {
//     if (_isLoading) {
//       return false;
//     }

//     if (_usingCurrentLocation) {
//       return fetchWeatherFromCurrentLocation();
//     }

//     final String? city = _lastSearchedCity;

//     if (city == null || city.trim().isEmpty) {
//       _errorMessage = 'No previous city is available to refresh.';
//       notifyListeners();
//       return false;
//     }

//     return fetchWeatherByCity(city);
//   }

//   void clearError() {
//     if (_errorMessage == null) {
//       return;
//     }

//     _errorMessage = null;
//     notifyListeners();
//   }

//   void setLoading(bool isLoading) {
//     _isLoading = isLoading;

//     if (isLoading) {
//       _errorMessage = null;
//     }
//     notifyListeners();
//   }

//   String _convertErrorToMessage(Object error) {
//     return error.toString().replaceFirst('Exception: ', '');
//   }
// }
