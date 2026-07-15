import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';

class HourlyForecastSection extends StatelessWidget {
  const HourlyForecastSection({
    super.key,
    required this.weatherData,
    this.showBackground = false,
    this.compact = false,
    this.padding = EdgeInsets.zero,
  });

  final WeatherForecastModel weatherData;
  final bool showBackground;
  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final forecasts = weatherData.forecastList;
    final int count = forecasts.length > 8 ? 8 : forecasts.length;

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        SizedBox(height: compact ? 12 : 16),
        SizedBox(
          height: compact ? 155 : 180,
          child: count == 0
              ? const Center(
                  child: Text(
                    'No hourly forecast available',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: count,
                  separatorBuilder: (context, index) {
                    return SizedBox(width: compact ? 10 : 12);
                  },
                  itemBuilder: (context, index) {
                    return _buildHourlyCard(
                      forecast: forecasts[index],
                      isCurrent: index == 0,
                    );
                  },
                ),
        ),
      ],
    );

    if (!showBackground) {
      return Padding(padding: padding, child: content);
    }

    return _glassContainer(padding: padding, child: content);
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: compact ? 38 : 42,
          height: compact ? 38 : 42,
          decoration: BoxDecoration(
            color: const Color(0xFFB8E7FF).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.schedule_rounded,
            color: const Color(0xFFB8E7FF),
            size: compact ? 20 : 22,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hourly Outlook',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Upcoming three-hour forecast',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyCard({
    required ForecastItem forecast,
    required bool isCurrent,
  }) {
    final WeatherCondition? condition = forecast.weather.isNotEmpty
        ? forecast.weather.first
        : null;

    final double? temperature = _toCelsius(forecast.main?.temperature);

    final int? rainChance = forecast.probabilityOfPrecipitation != null
        ? (forecast.probabilityOfPrecipitation! * 100).round()
        : null;

    return _glassContainer(
      width: compact ? 112 : 125,
      radius: compact ? 20 : 23,
      opacity: isCurrent ? 0.19 : 0.09,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 9 : 14,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 9,
              vertical: compact ? 4 : 5,
            ),
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFFB8E7FF).withValues(alpha: 0.20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              isCurrent ? 'NOW' : _formatTime(forecast.dateTimeText),
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 11 : 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          _buildWeatherIcon(
            iconCode: condition?.icon,
            condition: condition?.main,
            size: compact ? 48 : 58,
          ),
          Text(
            temperature != null ? '${temperature.toStringAsFixed(0)}°C' : '--',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 17 : 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, color: Color(0xFF9DDBFF), size: 13),
              const SizedBox(width: 3),
              Text(
                rainChance != null ? '$rainChance%' : '--',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon({
    required String? iconCode,
    required String? condition,
    required double size,
  }) {
    final String normalizedCondition = condition?.toLowerCase() ?? '';

    final bool isNight = iconCode?.endsWith('n') ?? false;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getWeatherIconGradient(
            condition: normalizedCondition,
            isNight: isNight,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: _getWeatherIconAccent(
                condition: normalizedCondition,
                isNight: isNight,
              ).withValues(alpha: 0.18),
              blurRadius: size * 0.25,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: _buildWeatherArtwork(
            condition: normalizedCondition,
            isNight: isNight,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherArtwork({
    required String condition,
    required bool isNight,
    required double size,
  }) {
    switch (condition) {
      case 'clear':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.48,
              height: size * 0.48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNight
                    ? const Color(0xFFFFE69B).withValues(alpha: 0.18)
                    : const Color(0xFFFFD36A).withValues(alpha: 0.18),
              ),
            ),
            Icon(
              isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: isNight
                  ? const Color(0xFFFFE69B)
                  : const Color(0xFFFFD36A),
              size: size * 0.58,
            ),
            if (isNight)
              Positioned(
                right: size * 0.12,
                top: size * 0.11,
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: size * 0.16,
                ),
              ),
          ],
        );

      case 'clouds':
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: size * 0.08,
              top: size * 0.18,
              child: Icon(
                Icons.cloud_rounded,
                color: const Color(0xFFB8D8EA).withValues(alpha: 0.65),
                size: size * 0.44,
              ),
            ),
            Positioned(
              right: size * 0.04,
              bottom: size * 0.08,
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.white,
                size: size * 0.62,
              ),
            ),
          ],
        );

      case 'rain':
      case 'drizzle':
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.06,
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.white,
                size: size * 0.59,
              ),
            ),
            ...List.generate(3, (index) {
              return Positioned(
                left: size * (0.26 + index * 0.20),
                bottom: size * (0.04 + (index.isOdd ? 0.05 : 0)),
                child: Transform.rotate(
                  angle: 0.28,
                  child: Container(
                    width: size * 0.055,
                    height: size * 0.22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7DD3FC),
                      borderRadius: BorderRadius.circular(size),
                    ),
                  ),
                ),
              );
            }),
          ],
        );

      case 'thunderstorm':
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.06,
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.white,
                size: size * 0.58,
              ),
            ),
            Positioned(
              bottom: size * 0.02,
              child: Icon(
                Icons.bolt_rounded,
                color: const Color(0xFFFFD54F),
                size: size * 0.48,
              ),
            ),
          ],
        );

      case 'snow':
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.04,
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.white,
                size: size * 0.56,
              ),
            ),
            Positioned(
              left: size * 0.20,
              bottom: size * 0.06,
              child: Icon(
                Icons.ac_unit_rounded,
                color: const Color(0xFFD9F4FF),
                size: size * 0.24,
              ),
            ),
            Positioned(
              right: size * 0.18,
              bottom: size * 0.02,
              child: Icon(
                Icons.ac_unit_rounded,
                color: Colors.white,
                size: size * 0.20,
              ),
            ),
          ],
        );

      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.10,
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.white.withValues(alpha: 0.90),
                size: size * 0.48,
              ),
            ),
            ...List.generate(3, (index) {
              return Positioned(
                bottom: size * (0.13 + index * 0.13),
                child: Container(
                  width: size * (0.62 - index * 0.08),
                  height: size * 0.055,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.62 - index * 0.10),
                    borderRadius: BorderRadius.circular(size),
                  ),
                ),
              );
            }),
          ],
        );

      default:
        return Icon(
          Icons.cloud_queue_rounded,
          color: Colors.white,
          size: size * 0.62,
        );
    }
  }

  LinearGradient _getWeatherIconGradient({
    required String condition,
    required bool isNight,
  }) {
    if (isNight) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x553A4D77), Color(0x3323375E)],
      );
    }

    switch (condition) {
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x55FFD56A), Color(0x22FFAA4A)],
        );

      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x5546B9E8), Color(0x223C7FA5)],
        );

      case 'thunderstorm':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x555E5A8A), Color(0x222D294C)],
        );

      case 'snow':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x66D9F4FF), Color(0x228DBDD3)],
        );

      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x55D2DCE2), Color(0x227A8C98)],
        );

      case 'clouds':
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x55B7D7E8), Color(0x2268869A)],
        );
    }
  }

  Color _getWeatherIconAccent({
    required String condition,
    required bool isNight,
  }) {
    if (isNight) {
      return const Color(0xFFB4C7FF);
    }

    switch (condition) {
      case 'clear':
        return const Color(0xFFFFD36A);

      case 'rain':
      case 'drizzle':
        return const Color(0xFF7DD3FC);

      case 'thunderstorm':
        return const Color(0xFFFFD54F);

      case 'snow':
        return const Color(0xFFD9F4FF);

      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return const Color(0xFFD2DCE2);

      case 'clouds':
      default:
        return const Color(0xFFB8D8EA);
    }
  }

  Widget _glassContainer({
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double radius = 24,
    double opacity = 0.10,
    double? width,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width ?? double.infinity,
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
    final DateTime? date = _parseDateTime(value);

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
}
