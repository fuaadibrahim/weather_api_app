import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';
import 'current_weather_card.dart';
import 'daily_forecast_section.dart';
import 'hourly_forecast_section.dart';
import 'weather_animation.dart';
import 'weather_metrics_section.dart';

class DesktopWeatherPage extends StatelessWidget {
  const DesktopWeatherPage({
    super.key,
    required this.cityController,
    required this.weatherData,
    required this.isLoading,
    required this.errorMessage,
    required this.onSearch,
    required this.onCurrentLocation,
    required this.onRefresh,
  });

  final TextEditingController cityController;
  final WeatherForecastModel? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onSearch;
  final Future<void> Function() onCurrentLocation;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final String cityName =
        weatherData?.city?.name ?? 'No city loaded';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30,
        18,
        30,
        24,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1400,
          ),
          child: Column(
            children: [
              _buildDesktopHeader(cityName),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildCurrentWeatherArea(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        physics:
                            const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          right: 4,
                          bottom: 4,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 250,
                              child:
                                  _buildHourlyForecastArea(),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 350,
                              child:
                                  _buildDailyForecastArea(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(String cityName) {
    return _glassContainer(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            child: const Icon(
              Icons.desktop_windows_rounded,
              color: Color(0xFFB8E7FF),
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weather Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoading
                      ? 'Fetching weather...'
                      : errorMessage ??
                            'Currently showing $cityName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 3,
            child: TextField(
              controller: cityController,
              enabled: !isLoading,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) {
                if (!isLoading) {
                  onSearch();
                }
              },
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search a city',
                hintStyle: const TextStyle(
                  color: Colors.white60,
                ),
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: Colors.white.withValues(
                  alpha: 0.09,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(
                      alpha: 0.16,
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(
                      alpha: 0.16,
                    ),
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(
                            color:
                                Color(0xFFB8E7FF),
                            width: 1.3,
                          ),
                    ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildIconButton(
            icon: Icons.my_location_rounded,
            tooltip: 'Use current location',
            onPressed: isLoading
                ? null
                : onCurrentLocation,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  isLoading ? null : () => onSearch(),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                backgroundColor:
                    const Color(0xFFB8E7FF),
                foregroundColor:
                    const Color(0xFF173B68),
                disabledBackgroundColor:
                    Colors.white.withValues(
                      alpha: 0.30,
                    ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child:
                          CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color:
                                Color(0xFF173B68),
                          ),
                    )
                  : const Icon(
                      Icons.search_rounded,
                      size: 25,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh weather',
            onPressed:
                isLoading ? null : onRefresh,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherArea() {
    if (isLoading) {
      return _buildLoadingPanel();
    }

    if (errorMessage != null &&
        weatherData == null) {
      return _buildPlaceholderPanel(
        icon: Icons.cloud_off_rounded,
        title: 'Unable to load weather',
        description: errorMessage!,
      );
    }

    if (weatherData == null ||
        weatherData!.forecastList.isEmpty) {
      return _buildPlaceholderPanel(
        icon: Icons.cloud_off_outlined,
        title: 'No weather available',
        description:
            'Search for a city or use your current location.',
      );
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(
        right: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          CurrentWeatherCard(
            weatherData: weatherData!,
            fallbackCity: cityController.text,
          ),
          const SizedBox(height: 18),
          WeatherMetricsSection(
            weatherData: weatherData!,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastArea() {
    if (isLoading && weatherData == null) {
      return _buildPlaceholderPanel(
        icon: Icons.cloud_sync_outlined,
        title: 'Loading hourly forecast',
        description:
            'Please wait while the latest forecast is loaded.',
      );
    }

    if (errorMessage != null &&
        weatherData == null) {
      return _buildPlaceholderPanel(
        icon: Icons.schedule_rounded,
        title: 'Hourly forecast unavailable',
        description: errorMessage!,
      );
    }

    if (weatherData == null ||
        weatherData!.forecastList.isEmpty) {
      return _buildPlaceholderPanel(
        icon: Icons.schedule_rounded,
        title: 'No hourly forecast',
        description:
            'Search for a city or use your current location.',
      );
    }

    return HourlyForecastSection(
      weatherData: weatherData!,
      showBackground: true,
      compact: true,
      padding: const EdgeInsets.all(18),
    );
  }

  Widget _buildDailyForecastArea() {
    if (isLoading && weatherData == null) {
      return _buildPlaceholderPanel(
        icon: Icons.cloud_sync_outlined,
        title: 'Loading daily forecast',
        description:
            'Please wait while the five-day forecast is loaded.',
      );
    }

    if (errorMessage != null &&
        weatherData == null) {
      return _buildPlaceholderPanel(
        icon: Icons.calendar_today_outlined,
        title: 'Daily forecast unavailable',
        description: errorMessage!,
      );
    }

    if (weatherData == null ||
        weatherData!.forecastList.isEmpty) {
      return _buildPlaceholderPanel(
        icon: Icons.calendar_today_outlined,
        title: 'No daily forecast',
        description:
            'Search for a city or use your current location.',
      );
    }

    return DailyForecastSection(
      weatherData: weatherData!,
      showBackground: true,
      compact: true,
      padding: const EdgeInsets.all(18),
    );
  }

  Widget _buildLoadingPanel() {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WeatherAnimation(
                condition: null,
                iconCode: null,
                isLoading: true,
                size: 210,
              ),
              const SizedBox(height: 4),
              const Text(
                'Fetching your weather',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Detecting the latest conditions for '
                '${cityController.text.trim().isEmpty ? 'your location' : cityController.text.trim()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required Future<void> Function()?
    onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed == null
            ? null
            : () {
                onPressed();
              },
        style: IconButton.styleFrom(
          backgroundColor:
              Colors.white.withValues(
                alpha: 0.10,
              ),
          disabledBackgroundColor:
              Colors.white.withValues(
                alpha: 0.05,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.white.withValues(
                alpha: 0.16,
              ),
            ),
          ),
        ),
        icon: Icon(
          icon,
          color: onPressed == null
              ? Colors.white38
              : Colors.white,
        ),
      ),
    );
  }

  Widget _buildPlaceholderPanel({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return _glassContainer(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFB8E7FF,
                  ).withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(21),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFFB8E7FF),
                  size: 31,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassContainer({
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.16,
              ),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.07,
                ),
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
}