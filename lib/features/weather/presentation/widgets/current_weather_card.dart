import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';
import 'weather_animation.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.weatherData,
    required this.fallbackCity,
  });

  final WeatherForecastModel weatherData;
  final String fallbackCity;

  ForecastItem? get currentForecast {
    final forecasts = weatherData.forecastList;

    if (forecasts.isEmpty) {
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
    final forecast = currentForecast;

    if (forecast == null) {
      return const SizedBox.shrink();
    }

    final condition = currentCondition;
    final city = weatherData.city;

    final temperature = _toCelsius(forecast.main?.temperature);
    final feelsLike = _toCelsius(forecast.main?.feelsLike);
    final range = _getTodayTemperatureRange();

    return _glassContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 760;

          final Widget animation = WeatherAnimation(
            condition: condition?.main,
            iconCode: condition?.icon,
            isLoading: false,
            size: isWide ? 285 : 235,
          );

          final Widget weatherDetails = Column(
            mainAxisSize: MainAxisSize.min,
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
                      '${city?.name ?? fallbackCity}'
                      '${city?.country?.isNotEmpty == true ? ', ${city!.country}' : ''}',
                      textAlign: isWide ? TextAlign.start : TextAlign.center,
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
                    temperature?.toStringAsFixed(0) ?? '--',
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
                _capitalize(condition?.description ?? 'Weather unavailable'),
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
                alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
                spacing: 9,
                runSpacing: 9,
                children: [
                  _buildWeatherChip(
                    icon: Icons.arrow_upward_rounded,
                    label: range.maximum != null
                        ? 'High ${range.maximum!.toStringAsFixed(0)}°'
                        : 'High --',
                  ),
                  _buildWeatherChip(
                    icon: Icons.arrow_downward_rounded,
                    label: range.minimum != null
                        ? 'Low ${range.minimum!.toStringAsFixed(0)}°'
                        : 'Low --',
                  ),
                  _buildWeatherChip(
                    icon: Icons.access_time_rounded,
                    label: _formatTime(forecast.dateTimeText),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [animation, const SizedBox(height: 4), weatherDetails],
          );
        },
      ),
    );
  }

  Widget _buildWeatherChip({required IconData icon, required String label}) {
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

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(32),
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
    final forecasts = weatherData.forecastList;

    if (forecasts.isEmpty) {
      return const _TemperatureRange();
    }

    final firstDate = _parseDateTime(forecasts.first.dateTimeText);

    if (firstDate == null) {
      return const _TemperatureRange();
    }

    double? minimum;
    double? maximum;

    for (final forecast in forecasts) {
      final date = _parseDateTime(forecast.dateTimeText);

      if (date == null ||
          date.year != firstDate.year ||
          date.month != firstDate.month ||
          date.day != firstDate.day) {
        continue;
      }

      final minimumValue = _toCelsius(
        forecast.main?.minimumTemperature ?? forecast.main?.temperature,
      );

      final maximumValue = _toCelsius(
        forecast.main?.maximumTemperature ?? forecast.main?.temperature,
      );

      if (minimumValue != null && (minimum == null || minimumValue < minimum)) {
        minimum = minimumValue;
      }

      if (maximumValue != null && (maximum == null || maximumValue > maximum)) {
        maximum = maximumValue;
      }
    }

    return _TemperatureRange(minimum: minimum, maximum: maximum);
  }

  double? _toCelsius(double? kelvin) {
    if (kelvin == null) {
      return null;
    }

    return kelvin - 273.15;
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.replaceFirst(' ', 'T'));
  }

  String _formatTime(String? value) {
    final date = _parseDateTime(value);

    if (date == null) {
      return '--';
    }

    int hour = date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');

    final String period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '$hour:$minute $period';
  }

  String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text[0].toUpperCase() + text.substring(1);
  }
}

class _TemperatureRange {
  const _TemperatureRange({this.minimum, this.maximum});

  final double? minimum;
  final double? maximum;
}
