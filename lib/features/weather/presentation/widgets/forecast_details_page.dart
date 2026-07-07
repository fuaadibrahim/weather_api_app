import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';

class ForecastDetailsPage extends StatelessWidget {
  final WeatherForecastModel? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onBackToCurrent;

  const ForecastDetailsPage({
    super.key,
    required this.weatherData,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onBackToCurrent,
  });

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
        final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 30.0;

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
        buildMetricsGrid(),
        const SizedBox(height: 34),
        buildSectionHeader(
          icon: Icons.schedule_rounded,
          title: 'Hourly Outlook',
          subtitle: 'Upcoming three-hour forecast',
        ),
        const SizedBox(height: 18),
        buildHourlyCards(),
        const SizedBox(height: 34),
        buildSectionHeader(
          icon: Icons.calendar_today_outlined,
          title: 'Five-Day Forecast',
          subtitle: 'Daily weather summary',
        ),
        const SizedBox(height: 18),
        buildDailyCards(),
        const SizedBox(height: 24),
        buildBackHint(),
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
    final forecast = currentForecast!;
    final condition = forecast.weather.isNotEmpty
        ? forecast.weather.first
        : null;

    final temperature = toCelsius(forecast.main?.temperature);

    return glassContainer(
      width: double.infinity,
      radius: 25,
      opacity: 0.11,
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 620;

          final iconAndTemperature = Row(
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

          final text = Column(
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

  Widget buildMetricsGrid() {
    final forecast = currentForecast!;

    final humidity = forecast.main?.humidity;
    final windSpeed = forecast.wind?.speed;
    final pressure = forecast.main?.pressure;

    final rainChance = forecast.probabilityOfPrecipitation != null
        ? (forecast.probabilityOfPrecipitation! * 100).round()
        : null;

    return glassContainer(
      width: double.infinity,
      radius: 24,
      opacity: 0.10,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          final humidityItem = buildSimpleMetricItem(
            icon: Icons.water_drop_outlined,
            label: 'Humidity',
            value: humidity != null ? '$humidity%' : '--',
            accent: const Color(0xFF66D5FF),
          );

          final windItem = buildSimpleMetricItem(
            icon: Icons.air_rounded,
            label: 'Wind',
            value: windSpeed != null
                ? '${windSpeed.toStringAsFixed(1)} m/s'
                : '--',
            accent: const Color(0xFF99E8D7),
          );

          final rainItem = buildSimpleMetricItem(
            icon: Icons.umbrella_outlined,
            label: 'Rain',
            value: rainChance != null ? '$rainChance%' : '--',
            accent: const Color(0xFFB4A6FF),
          );

          final pressureItem = buildSimpleMetricItem(
            icon: Icons.speed_rounded,
            label: 'Pressure',
            value: pressure != null ? '$pressure hPa' : '--',
            accent: const Color(0xFFFFCA80),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: humidityItem),
                buildMetricDivider(vertical: true),
                Expanded(child: windItem),
                buildMetricDivider(vertical: true),
                Expanded(child: rainItem),
                buildMetricDivider(vertical: true),
                Expanded(child: pressureItem),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: humidityItem),
                  buildMetricDivider(vertical: true),
                  Expanded(child: windItem),
                ],
              ),
              buildMetricDivider(vertical: false),
              Row(
                children: [
                  Expanded(child: rainItem),
                  buildMetricDivider(vertical: true),
                  Expanded(child: pressureItem),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSimpleMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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

  Widget buildMetricDivider({required bool vertical}) {
    if (vertical) {
      return Container(
        width: 1,
        height: 48,
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

  Widget buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFB8E7FF).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFFB8E7FF), size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildHourlyCards() {
    final forecasts = weatherData!.forecastList;
    final count = forecasts.length > 8 ? 8 : forecasts.length;

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final forecast = forecasts[index];

          final condition = forecast.weather.isNotEmpty
              ? forecast.weather.first
              : null;

          final temperature = toCelsius(forecast.main?.temperature);

          final rainChance = forecast.probabilityOfPrecipitation != null
              ? (forecast.probabilityOfPrecipitation! * 100).round()
              : null;

          return glassContainer(
            width: 125,
            radius: 23,
            opacity: index == 0 ? 0.19 : 0.09,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xFFB8E7FF).withValues(alpha: 0.20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    index == 0 ? 'NOW' : formatTime(forecast.dateTimeText),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: index == 0
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
                buildWeatherIcon(
                  iconCode: condition?.icon,
                  condition: condition?.main,
                  size: 58,
                ),
                Text(
                  temperature != null
                      ? '${temperature.toStringAsFixed(0)}°C'
                      : '--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: Color(0xFF9DDBFF),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rainChance != null ? '$rainChance%' : '--',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDailyCards() {
    final summaries = _createDailySummaries().take(5).toList();

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: summaries.length,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 13);
        },
        itemBuilder: (context, index) {
          final summary = summaries[index];

          return glassContainer(
            width: 210,
            radius: 25,
            opacity: 0.10,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0 ? 'Today' : formatWeekday(summary.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatShortDate(summary.date),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Center(
                  child: buildWeatherIcon(
                    iconCode: summary.iconCode,
                    condition: summary.condition,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  capitalize(summary.description ?? 'Weather'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    buildTemperatureBadge(
                      label: 'HIGH',
                      value:
                          '${summary.maximumTemperature.toStringAsFixed(0)}°',
                      color: const Color(0xFFFFD18A),
                    ),
                    const SizedBox(width: 7),
                    buildTemperatureBadge(
                      label: 'LOW',
                      value:
                          '${summary.minimumTemperature.toStringAsFixed(0)}°',
                      color: const Color(0xFF9DDBFF),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.umbrella_outlined,
                            color: Color(0xFF9DDBFF),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Rain chance',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            '${summary.rainChance}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop_outlined,
                            color: Color(0xFF9DDBFF),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Humidity',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            '${summary.averageHumidity}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
        },
      ),
    );
  }

  Widget buildTemperatureBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
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
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBackHint() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onBackToCurrent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Row(
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
    final normalizedCondition = condition?.toLowerCase() ?? '';
    final isNight = iconCode?.endsWith('n') ?? false;

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

  List<_DailySummary> _createDailySummaries() {
    final grouped = <String, List<ForecastItem>>{};

    for (final forecast in weatherData?.forecastList ?? []) {
      final date = parseDateTime(forecast.dateTimeText);

      if (date == null) continue;

      final key =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(key, () => []);

      grouped[key]!.add(forecast);
    }

    final summaries = <_DailySummary>[];

    for (final entry in grouped.entries) {
      final forecasts = entry.value;

      if (forecasts.isEmpty) continue;

      double? minimum;
      double? maximum;
      int highestRainChance = 0;
      int totalHumidity = 0;
      int humidityCount = 0;

      ForecastItem representative = forecasts.first;
      int closestToMidday = 24;

      for (final forecast in forecasts) {
        final minimumValue = toCelsius(
          forecast.main?.minimumTemperature ?? forecast.main?.temperature,
        );

        final maximumValue = toCelsius(
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

        final date = parseDateTime(forecast.dateTimeText);

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

  String formatWeekday(DateTime date) {
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

  String formatShortDate(DateTime date) {
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

  String capitalize(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1);
  }

  IconData getFallbackIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;

      case 'clouds':
        return Icons.cloud_rounded;

      case 'rain':
        return Icons.water_drop_rounded;

      case 'drizzle':
        return Icons.grain_rounded;

      case 'thunderstorm':
        return Icons.thunderstorm_rounded;

      case 'snow':
        return Icons.ac_unit_rounded;

      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return Icons.foggy;

      default:
        return Icons.cloud_queue_rounded;
    }
  }
}

class _DailySummary {
  final DateTime date;
  final double minimumTemperature;
  final double maximumTemperature;
  final int rainChance;
  final int averageHumidity;
  final String? iconCode;
  final String? condition;
  final String? description;

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
}
