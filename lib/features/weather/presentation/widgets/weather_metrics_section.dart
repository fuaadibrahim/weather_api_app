import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';

class WeatherMetricsSection extends StatelessWidget {
  const WeatherMetricsSection({
    super.key,
    required this.weatherData,
    this.compact = false,
  });

  final WeatherForecastModel weatherData;
  final bool compact;

  ForecastItem? get currentForecast {
    final forecasts = weatherData.forecastList;

    if (forecasts.isEmpty) {
      return null;
    }

    return forecasts.first;
  }

  @override
  Widget build(BuildContext context) {
    final ForecastItem? forecast = currentForecast;

    if (forecast == null) {
      return _buildEmptyState();
    }

    final int? humidity = forecast.main?.humidity;
    final double? windSpeed = forecast.wind?.speed;
    final int? pressure = forecast.main?.pressure;

    final int? rainChance = forecast.probabilityOfPrecipitation != null
        ? (forecast.probabilityOfPrecipitation! * 100).round()
        : null;

    final Widget humidityItem = _buildMetricItem(
      icon: Icons.water_drop_outlined,
      label: 'Humidity',
      value: humidity != null ? '$humidity%' : '--',
      accent: const Color(0xFF66D5FF),
    );

    final Widget windItem = _buildMetricItem(
      icon: Icons.air_rounded,
      label: 'Wind',
      value: windSpeed != null ? '${windSpeed.toStringAsFixed(1)} m/s' : '--',
      accent: const Color(0xFF99E8D7),
    );

    final Widget rainItem = _buildMetricItem(
      icon: Icons.umbrella_outlined,
      label: 'Rain',
      value: rainChance != null ? '$rainChance%' : '--',
      accent: const Color(0xFFB4A6FF),
    );

    final Widget pressureItem = _buildMetricItem(
      icon: Icons.speed_rounded,
      label: 'Pressure',
      value: pressure != null ? '$pressure hPa' : '--',
      accent: const Color(0xFFFFCA80),
    );

    return _glassContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool useSingleRow = !compact && constraints.maxWidth >= 700;

          if (useSingleRow) {
            return Row(
              children: [
                Expanded(child: humidityItem),
                _buildDivider(vertical: true),
                Expanded(child: windItem),
                _buildDivider(vertical: true),
                Expanded(child: rainItem),
                _buildDivider(vertical: true),
                Expanded(child: pressureItem),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: humidityItem),
                  _buildDivider(vertical: true),
                  Expanded(child: windItem),
                ],
              ),
              _buildDivider(vertical: false),
              Row(
                children: [
                  Expanded(child: rainItem),
                  _buildDivider(vertical: true),
                  Expanded(child: pressureItem),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 10 : 14,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 36 : 42,
            height: compact ? 36 : 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(compact ? 11 : 13),
            ),
            child: Icon(icon, color: accent, size: compact ? 18 : 21),
          ),
          SizedBox(width: compact ? 8 : 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: compact ? 10 : 11,
                  ),
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider({required bool vertical}) {
    if (vertical) {
      return Container(
        width: 1,
        height: compact ? 40 : 48,
        color: Colors.white.withValues(alpha: 0.12),
      );
    }

    return Container(
      width: double.infinity,
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  Widget _buildEmptyState() {
    return _glassContainer(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Center(
          child: Text(
            'Weather details are unavailable',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 10 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
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
}
