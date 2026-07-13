import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';
import 'weather_animation.dart';

class CurrentWeatherPage extends StatelessWidget {
  final TextEditingController cityController;
  final WeatherForecastModel? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onSearch;
  final Future<void> Function() onCurrentLocation;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenForecast;

  const CurrentWeatherPage({
    super.key,
    required this.cityController,
    required this.weatherData,
    required this.isLoading,
    required this.errorMessage,
    required this.onSearch,
    required this.onCurrentLocation,
    required this.onRefresh,
    required this.onOpenForecast,
  });

  ForecastItem? get currentForecast {
    final forecasts = weatherData?.forecastList;

    if (forecasts == null || forecasts.isEmpty) {
      return null;
    }

    return forecasts.first;
  }

  WeatherCondition? get currentCondition {
    final forecast = currentForecast;

    if (forecast == null || forecast.weather.isEmpty) {
      return null;
    }

    return forecast.weather.first;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 30.0;

        return RefreshIndicator(
          onRefresh: onRefresh,
          color: Colors.white,
          backgroundColor: const Color(0xFF293E68),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 20),
                    buildSearchBar(),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: buildPageContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: const Icon(
            Icons.cloud_outlined,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Current weather and live conditions',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        buildGlassIconButton(
          icon: Icons.refresh_rounded,
          onPressed: isLoading ? null : () => onRefresh(),
          tooltip: 'Refresh weather',
        ),
      ],
    );
  }

  Widget buildGlassIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: onPressed == null ? Colors.white38 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return glassContainer(
      radius: 22,
      opacity: 0.11,
      padding: const EdgeInsets.all(7),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: cityController,
              enabled: !isLoading,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onSubmitted: (_) {
                if (!isLoading) {
                  onSearch();
                }
              },
              decoration: const InputDecoration(
                hintText: 'Search a city',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 50,
            height: 50,
            child: IconButton(
              tooltip: 'Use current location',
              onPressed: isLoading ? null : () => onCurrentLocation(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                ),
              ),
              icon: Icon(
                Icons.my_location_rounded,
                color: isLoading ? Colors.white38 : Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 55,
            height: 55,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => onSearch(),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFB8E7FF),
                foregroundColor: const Color(0xFF153A67),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Color(0xFF153A67),
                      ),
                    )
                  : const Icon(Icons.search_rounded, size: 27),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageContent() {
    if (isLoading) {
      return buildLoadingState();
    }

    if (errorMessage != null) {
      return buildErrorState();
    }

    if (weatherData == null || weatherData!.forecastList.isEmpty) {
      return buildEmptyState();
    }

    return buildCurrentWeather();
  }

  Widget buildLoadingState() {
    return glassContainer(
      key: const ValueKey('loading'),
      width: double.infinity,
      radius: 30,
      opacity: 0.11,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const WeatherAnimation(
            condition: null,
            iconCode: null,
            isLoading: true,
            size: 245,
          ),
          const SizedBox(height: 2),
          const Text(
            'Fetching your weather',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detecting the latest conditions for ${cityController.text.trim().isEmpty ? 'your location' : cityController.text.trim()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorState() {
    return glassContainer(
      key: const ValueKey('error'),
      width: double.infinity,
      radius: 30,
      opacity: 0.11,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 68),
          const SizedBox(height: 18),
          const Text(
            'Unable to load the forecast',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => onSearch(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try city again'),
                style: primaryButtonStyle(),
              ),
              OutlinedButton.icon(
                onPressed: () => onCurrentLocation(),
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Use location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return glassContainer(
      key: const ValueKey('empty'),
      width: double.infinity,
      radius: 30,
      opacity: 0.10,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 70),
      child: const Column(
        children: [
          Icon(Icons.cloud_off_outlined, color: Colors.white, size: 65),
          SizedBox(height: 18),
          Text(
            'Please check your internet connection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentWeather() {
    final forecast = currentForecast!;
    final condition = currentCondition;
    final city = weatherData?.city;

    final temperature = toCelsius(forecast.main?.temperature);

    final feelsLike = toCelsius(forecast.main?.feelsLike);

    final range = _getTodayTemperatureRange();

    return Column(
      key: const ValueKey('weather'),
      children: [
        glassContainer(
          width: double.infinity,
          radius: 32,
          opacity: 0.13,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              final animation = WeatherAnimation(
                condition: condition?.main,
                iconCode: condition?.icon,
                isLoading: false,
                size: isWide ? 285 : 235,
              );

              final weatherDetails = Column(
                crossAxisAlignment: isWide
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        color: Color(0xFFB9E9FF),
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          '${city?.name ?? cityController.text}'
                          '${city?.country?.isNotEmpty == true ? ', ${city!.country}' : ''}',
                          textAlign: isWide
                              ? TextAlign.start
                              : TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temperature != null
                            ? temperature.toStringAsFixed(0)
                            : '--',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWide ? 78 : 68,
                          fontWeight: FontWeight.bold,
                          height: 0.95,
                          letterSpacing: -3,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          '°C',
                          style: TextStyle(
                            color: Color(0xFFB9E9FF),
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    capitalize(condition?.description ?? 'Weather unavailable'),
                    textAlign: isWide ? TextAlign.start : TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Feels like ${feelsLike?.toStringAsFixed(1) ?? '--'}°C',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: isWide
                        ? WrapAlignment.start
                        : WrapAlignment.center,
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      buildWeatherChip(
                        icon: Icons.arrow_upward_rounded,
                        label: range.maximum != null
                            ? 'High ${range.maximum!.toStringAsFixed(0)}°'
                            : 'High --',
                      ),
                      buildWeatherChip(
                        icon: Icons.arrow_downward_rounded,
                        label: range.minimum != null
                            ? 'Low ${range.minimum!.toStringAsFixed(0)}°'
                            : 'Low --',
                      ),
                      buildWeatherChip(
                        icon: Icons.access_time_rounded,
                        label: formatTime(forecast.dateTimeText),
                      ),
                    ],
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: animation),
                    const SizedBox(width: 30),
                    Expanded(child: weatherDetails),
                  ],
                );
              }

              return Column(
                children: [
                  animation,
                  const SizedBox(height: 4),
                  weatherDetails,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        buildForecastNavigationCard(),
      ],
    );
  }

  Widget buildForecastNavigationCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenForecast,
        borderRadius: BorderRadius.circular(24),
        child: glassContainer(
          width: double.infinity,
          radius: 24,
          opacity: 0.11,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB8E7FF), Color(0xFF7FCBFF)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7FCBFF).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Color(0xFF173B68),
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore the forecast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hourly details and 5-day outlook',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFB8E7FF),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWeatherChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFB9E9FF), size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: const Color(0xFF173B68),
      backgroundColor: const Color(0xFFB8E7FF),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget glassContainer({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double radius = 24,
    double opacity = 0.10,
    double? width,
    double? height,
  }) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  _TemperatureRange _getTodayTemperatureRange() {
    final forecasts = weatherData?.forecastList ?? [];

    if (forecasts.isEmpty) {
      return const _TemperatureRange();
    }

    final firstDate = parseDateTime(forecasts.first.dateTimeText);

    if (firstDate == null) {
      return const _TemperatureRange();
    }

    double? minimum;
    double? maximum;

    for (final forecast in forecasts) {
      final date = parseDateTime(forecast.dateTimeText);

      if (date == null ||
          date.year != firstDate.year ||
          date.month != firstDate.month ||
          date.day != firstDate.day) {
        continue;
      }

      final minValue = toCelsius(
        forecast.main?.minimumTemperature ?? forecast.main?.temperature,
      );

      final maxValue = toCelsius(
        forecast.main?.maximumTemperature ?? forecast.main?.temperature,
      );

      if (minValue != null && (minimum == null || minValue < minimum)) {
        minimum = minValue;
      }

      if (maxValue != null && (maximum == null || maxValue > maximum)) {
        maximum = maxValue;
      }
    }

    return _TemperatureRange(minimum: minimum, maximum: maximum);
  }

  double? toCelsius(double? kelvin) {
    if (kelvin == null) return null;

    return kelvin - 273.15;
  }

  DateTime? parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.replaceFirst(' ', 'T'));
  }

  String formatTime(String? value) {
    final date = parseDateTime(value);

    if (date == null) return '--';

    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '$hour:$minute $period';
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1);
  }
}

class _TemperatureRange {
  final double? minimum;
  final double? maximum;

  const _TemperatureRange({this.minimum, this.maximum});
}
