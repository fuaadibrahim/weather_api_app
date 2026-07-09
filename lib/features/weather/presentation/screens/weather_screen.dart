import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';
import '../widgets/current_weather_page.dart';
import '../widgets/forecast_details_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController();
  final PageController pageController = PageController();

  int currentPage = 0;

  Future<void> _fetchWeatherFromCurrentLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();

    context.read<WeatherBloc>().add(const FetchCurrentLocationWeather());
  }

  Future<void> _fetchWeatherByCity() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final String city = cityController.text.trim();

    if (city.isEmpty) {
      return;
    }

    context.read<WeatherBloc>().add(SearchWeatherByCity(city));
  }

  Future<void> _refreshWeather() async {
    FocusManager.instance.primaryFocus?.unfocus();

    context.read<WeatherBloc>().add(const RefreshWeather());
  }

  void openPage(int page) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!pageController.hasClients) {
      return;
    }

    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  ForecastItem? currentForecastFrom(WeatherForecastModel? weatherData) {
    final forecasts = weatherData?.forecastList;

    if (forecasts == null || forecasts.isEmpty) {
      return null;
    }

    return forecasts.first;
  }

  WeatherCondition? currentConditionFrom(WeatherForecastModel? weatherData) {
    final ForecastItem? forecast = currentForecastFrom(weatherData);

    if (forecast == null || forecast.weather.isEmpty) {
      return null;
    }

    return forecast.weather.first;
  }

  @override
  void initState() {
    super.initState();

    context.read<WeatherBloc>().add(const InitializeWeather());
  }

  @override
  void dispose() {
    cityController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        final weatherData = state.weatherData;

        if (state.isLoading && weatherData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 650),
            decoration: BoxDecoration(
              gradient: getBackgroundGradient(weatherData),
            ),
            child: Stack(
              children: [
                buildBackgroundShapes(),
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (int page) {
                            setState(() {
                              currentPage = page;
                            });
                          },
                          children: [
                            CurrentWeatherPage(
                              cityController: cityController,
                              weatherData: weatherData,
                              isLoading: state.isLoading,
                              errorMessage: state.errorMessage,
                              onSearch: _fetchWeatherByCity,
                              onCurrentLocation:
                                  _fetchWeatherFromCurrentLocation,
                              onRefresh: _refreshWeather,
                              onOpenForecast: () => openPage(1),
                            ),

                            ForecastDetailsPage(
                              weatherData: weatherData,
                              isLoading: state.isLoading,
                              errorMessage: state.errorMessage,
                              onRefresh: _refreshWeather,
                              onBackToCurrent: () => openPage(0),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: buildPageIndicator(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPageIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildIndicatorDot(
                page: 0,
                icon: Icons.wb_cloudy_outlined,
                tooltip: 'Current weather',
              ),
              const SizedBox(width: 7),
              buildIndicatorDot(
                page: 1,
                icon: Icons.view_timeline_outlined,
                tooltip: 'Detailed forecast',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicatorDot({
    required int page,
    required IconData icon,
    required String tooltip,
  }) {
    final bool selected = currentPage == page;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openPage(page),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: selected ? 52 : 34,
          height: 30,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFB8E7FF)
                : Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 17,
            color: selected ? const Color(0xFF173B68) : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget buildBackgroundShapes() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: buildBlurredCircle(
              size: 340,
              color: const Color(0xFF9DE4FF),
              opacity: 0.18,
            ),
          ),
          Positioned(
            top: 390,
            left: -150,
            child: buildBlurredCircle(
              size: 360,
              color: const Color(0xFF876CFF),
              opacity: 0.12,
            ),
          ),
          Positioned(
            bottom: -130,
            right: -80,
            child: buildBlurredCircle(
              size: 330,
              color: Colors.white,
              opacity: 0.10,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBlurredCircle({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }

  LinearGradient getBackgroundGradient(WeatherForecastModel? weatherData) {
    final WeatherCondition? currentCondition = currentConditionFrom(
      weatherData,
    );

    final String? condition = currentCondition?.main?.toLowerCase();

    final String? iconCode = currentCondition?.icon;

    final bool isNight = iconCode?.endsWith('n') ?? false;

    if (isNight) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF111C39), Color(0xFF24375C), Color(0xFF3F4773)],
      );
    }

    switch (condition) {
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1674C9), Color(0xFF2E99D2), Color(0xFF4C76B8)],
        );

      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF263D59), Color(0xFF41627A), Color(0xFF535A7D)],
        );

      case 'thunderstorm':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20243C), Color(0xFF3E405F), Color(0xFF594C70)],
        );

      case 'clouds':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF365C77), Color(0xFF557A91), Color(0xFF6C6A8E)],
        );

      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4D6472), Color(0xFF71818B), Color(0xFF77748A)],
        );

      case 'snow':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6588A1), Color(0xFF93AFC0), Color(0xFF9695B7)],
        );

      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C6EB5), Color(0xFF3798C9), Color(0xFF5369A8)],
        );
    }
  }
}
