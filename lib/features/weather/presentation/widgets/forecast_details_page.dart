import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';
import 'daily_forecast_section.dart';
import 'hourly_forecast_section.dart';
import 'weather_metrics_section.dart';

class ForecastDetailsPage extends StatelessWidget {
  const ForecastDetailsPage({
    super.key,
    required this.weatherData,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onBackToCurrent,
  });

  final WeatherForecastModel? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onBackToCurrent;

  bool get isNativeWindows {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  ForecastItem? get currentForecast {
    final forecasts = weatherData?.forecastList;

    if (forecasts == null || forecasts.isEmpty) {
      return null;
    }

    return forecasts.first;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding = constraints.maxWidth < 600 ? 16 : 30;

        return RefreshIndicator(
          onRefresh: onRefresh,
          color: Colors.white,
          backgroundColor: const Color(0xFF293E68),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              26,
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
                    const SizedBox(height: 28),
                    buildContent(),
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
    final city = weatherData?.city;

    return Row(
      children: [
        buildGlassIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: onBackToCurrent,
          tooltip: 'Back to current weather',
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${city?.name ?? 'Forecast'}'
                '${city?.country?.isNotEmpty == true ? ', ${city!.country}' : ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Hourly outlook and five-day forecast',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        buildGlassIconButton(
          icon: Icons.refresh_rounded,
          onPressed: isLoading ? null : () => onRefresh(),
          tooltip: 'Refresh forecast',
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

  Widget buildContent() {
    if (isLoading && weatherData == null) {
      return buildLoadingState();
    }

    if (errorMessage != null && weatherData == null) {
      return buildErrorState();
    }

    if (weatherData == null || weatherData!.forecastList.isEmpty) {
      return buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCurrentSummary(),
        const SizedBox(height: 26),

        WeatherMetricsSection(weatherData: weatherData!),

        const SizedBox(height: 34),

        HourlyForecastSection(weatherData: weatherData!),

        const SizedBox(height: 34),

        DailyForecastSection(weatherData: weatherData!),

        if (!isNativeWindows) ...[const SizedBox(height: 24), buildBackHint()],

        const SizedBox(height: 18),
      ],
    );
  }

  Widget buildLoadingState() {
    return glassContainer(
      width: double.infinity,
      radius: 28,
      opacity: 0.10,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
      child: const Column(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Loading detailed forecast',
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

  Widget buildErrorState() {
    return glassContainer(
      width: double.infinity,
      radius: 28,
      opacity: 0.11,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 55),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 68),
          const SizedBox(height: 18),
          const Text(
            'Detailed forecast unavailable',
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
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: onBackToCurrent,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to search'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: const Color(0xFF173B68),
              backgroundColor: const Color(0xFFB8E7FF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return glassContainer(
      width: double.infinity,
      radius: 28,
      opacity: 0.10,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 70),
      child: Column(
        children: [
          const Icon(
            Icons.view_timeline_outlined,
            color: Colors.white,
            size: 65,
          ),
          const SizedBox(height: 18),
          const Text(
            'Search for weather first',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onBackToCurrent,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Go to search'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: const Color(0xFF173B68),
              backgroundColor: const Color(0xFFB8E7FF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentSummary() {
    final ForecastItem forecast = currentForecast!;

    final WeatherCondition? condition = forecast.weather.isNotEmpty
        ? forecast.weather.first
        : null;

    final double? temperature = toCelsius(forecast.main?.temperature);

    return glassContainer(
      width: double.infinity,
      radius: 25,
      opacity: 0.11,
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 620;

          final Widget iconAndTemperature = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildWeatherIcon(
                iconCode: condition?.icon,
                condition: condition?.main,
                size: 72,
              ),
              const SizedBox(width: 3),
              Text(
                temperature != null
                    ? '${temperature.toStringAsFixed(0)}°'
                    : '--',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 43,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -2,
                ),
              ),
            ],
          );

          final Widget text = Column(
            crossAxisAlignment: isWide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                capitalize(condition?.description ?? 'Weather'),
                textAlign: isWide ? TextAlign.start : TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Updated for ${formatTime(forecast.dateTimeText)}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                iconAndTemperature,
                const SizedBox(width: 18),
                Expanded(child: text),
                if (!isNativeWindows)
                  const Icon(
                    Icons.swipe_right_alt_rounded,
                    color: Colors.white38,
                    size: 32,
                  ),
              ],
            );
          }
          return Column(
            children: [iconAndTemperature, const SizedBox(height: 8), text],
          );
        },
      ),
    );
  }

  Widget buildBackHint() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onBackToCurrent,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_rounded, color: Colors.white60, size: 17),
            SizedBox(width: 7),
            Text(
              'Swipe right to return to current weather',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget glassContainer({
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double radius = 24,
    double opacity = 0.10,
    double? width,
    double? height,
  }) {
    return ClipRRect(
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

  Widget buildWeatherIcon({
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
          gradient: getWeatherIconGradient(
            condition: normalizedCondition,
            isNight: isNight,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: getWeatherIconAccent(
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
          child: buildWeatherArtwork(
            condition: normalizedCondition,
            isNight: isNight,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget buildWeatherArtwork({
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

      case 'drizzle':
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.08,
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.white,
                size: size * 0.56,
              ),
            ),
            ...List.generate(4, (index) {
              return Positioned(
                left: size * (0.20 + index * 0.18),
                bottom: size * 0.07,
                child: Container(
                  width: size * 0.045,
                  height: size * 0.13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9DDBFF),
                    borderRadius: BorderRadius.circular(size),
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

  LinearGradient getWeatherIconGradient({
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

  Color getWeatherIconAccent({
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

  double? toCelsius(double? kelvin) {
    if (kelvin == null) {
      return null;
    }

    return kelvin - 273.15;
  }

  DateTime? parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.replaceFirst(' ', 'T'));
  }

  String formatTime(String? value) {
    final DateTime? date = parseDateTime(value);

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

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text[0].toUpperCase() + text.substring(1);
  }
}
