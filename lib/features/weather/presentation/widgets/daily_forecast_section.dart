import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';

class DailyForecastSection extends StatelessWidget {
  const DailyForecastSection({
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
    final summaries = _createDailySummaries().take(5).toList();

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        SizedBox(height: compact ? 8 : 18),
        SizedBox(
          height: compact ? 250 : 320,
          child: summaries.isEmpty
              ? const Center(
                  child: Text(
                    'No daily forecast available',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: summaries.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(width: compact ? 10 : 13);
                  },
                  itemBuilder: (context, index) {
                    return _buildDailyCard(
                      summary: summaries[index],
                      index: index,
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
            Icons.calendar_today_outlined,
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
                'Five-Day Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Daily weather summary',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyCard({required _DailySummary summary, required int index}) {
    return _glassContainer(
      width: compact ? 150 : 210,
      radius: compact ? 20 : 25,
      opacity: 0.10,
      padding: EdgeInsets.all(compact ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index == 0 ? 'Today' : _formatWeekday(summary.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 15 : 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: compact ? 2 : 3),
          Text(
            _formatShortDate(summary.date),
            style: TextStyle(
              color: Colors.white54,
              fontSize: compact ? 11 : 12,
            ),
          ),
          SizedBox(height: compact ? 6 : 10),
          Center(
            child: _buildWeatherIcon(
              iconCode: summary.iconCode,
              condition: summary.condition,
              size: compact ? 48 : 60,
            ),
          ),
          SizedBox(height: compact ? 5 : 8),
          Text(
            _capitalize(summary.description ?? 'Weather'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          Row(
            children: [
              _buildTemperatureBadge(
                label: 'HIGH',
                value: '${summary.maximumTemperature.toStringAsFixed(0)}°',
                color: const Color(0xFFFFD18A),
              ),
              SizedBox(width: compact ? 5 : 7),
              _buildTemperatureBadge(
                label: 'LOW',
                value: '${summary.minimumTemperature.toStringAsFixed(0)}°',
                color: const Color(0xFF9DDBFF),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 7 : 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.umbrella_outlined,
                      color: const Color(0xFF9DDBFF),
                      size: compact ? 13 : 15,
                    ),
                    SizedBox(width: compact ? 4 : 6),
                    Expanded(
                      child: Text(
                        compact ? 'Rain' : 'Rain chance',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: compact ? 9 : 11,
                        ),
                      ),
                    ),
                    Text(
                      '${summary.rainChance}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 6 : 8),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      color: const Color(0xFF9DDBFF),
                      size: compact ? 13 : 15,
                    ),
                    SizedBox(width: compact ? 4 : 6),
                    Expanded(
                      child: Text(
                        'Humidity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: compact ? 9 : 11,
                        ),
                      ),
                    ),
                    Text(
                      '${summary.averageHumidity}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 8,
          vertical: compact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

  List<_DailySummary> _createDailySummaries() {
    final grouped = <String, List<ForecastItem>>{};

    for (final forecast in weatherData.forecastList) {
      final date = _parseDateTime(forecast.dateTimeText);

      if (date == null) {
        continue;
      }

      final String key =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(forecast);
    }

    final summaries = <_DailySummary>[];

    for (final entry in grouped.entries) {
      final forecasts = entry.value;

      if (forecasts.isEmpty) {
        continue;
      }

      double? minimum;
      double? maximum;
      int highestRainChance = 0;
      int totalHumidity = 0;
      int humidityCount = 0;

      ForecastItem representative = forecasts.first;
      int closestToMidday = 24;

      for (final forecast in forecasts) {
        final minimumValue = _toCelsius(
          forecast.main?.minimumTemperature ?? forecast.main?.temperature,
        );

        final maximumValue = _toCelsius(
          forecast.main?.maximumTemperature ?? forecast.main?.temperature,
        );

        if (minimumValue != null &&
            (minimum == null || minimumValue < minimum)) {
          minimum = minimumValue;
        }

        if (maximumValue != null &&
            (maximum == null || maximumValue > maximum)) {
          maximum = maximumValue;
        }

        final rainProbability = forecast.probabilityOfPrecipitation;

        if (rainProbability != null) {
          final rainChance = (rainProbability * 100).round();

          if (rainChance > highestRainChance) {
            highestRainChance = rainChance;
          }
        }

        final humidity = forecast.main?.humidity;

        if (humidity != null) {
          totalHumidity += humidity;
          humidityCount++;
        }

        final date = _parseDateTime(forecast.dateTimeText);

        if (date != null) {
          final distance = (date.hour - 12).abs();

          if (distance < closestToMidday) {
            closestToMidday = distance;
            representative = forecast;
          }
        }
      }

      final representativeCondition = representative.weather.isNotEmpty
          ? representative.weather.first
          : null;

      final date = DateTime.tryParse(entry.key);

      if (date == null || minimum == null || maximum == null) {
        continue;
      }

      summaries.add(
        _DailySummary(
          date: date,
          minimumTemperature: minimum,
          maximumTemperature: maximum,
          rainChance: highestRainChance,
          averageHumidity: humidityCount == 0
              ? 0
              : (totalHumidity / humidityCount).round(),
          iconCode: representativeCondition?.icon,
          condition: representativeCondition?.main,
          description: representativeCondition?.description,
        ),
      );
    }

    summaries.sort((a, b) => a.date.compareTo(b.date));

    return summaries;
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

  String _formatWeekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return weekdays[date.weekday - 1];
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text[0].toUpperCase() + text.substring(1);
  }
}

class _DailySummary {
  const _DailySummary({
    required this.date,
    required this.minimumTemperature,
    required this.maximumTemperature,
    required this.rainChance,
    required this.averageHumidity,
    required this.iconCode,
    required this.condition,
    required this.description,
  });

  final DateTime date;
  final double minimumTemperature;
  final double maximumTemperature;
  final int rainChance;
  final int averageHumidity;
  final String? iconCode;
  final String? condition;
  final String? description;
}
