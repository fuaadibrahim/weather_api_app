import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/weather_forecast_model.dart';
import 'current_weather_card.dart';
import 'weather_animation.dart';

class CurrentWeatherPage extends StatelessWidget {
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

  final TextEditingController cityController;
  final WeatherForecastModel? weatherData;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onSearch;
  final Future<void> Function() onCurrentLocation;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenForecast;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding = constraints.maxWidth < 600 ? 16 : 30;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            18,
            horizontalPadding,
            0,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 20),
                    buildSearchBar(),
                    const SizedBox(height: 18),

                    // Only the weather content below the search bar scrolls.
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: onRefresh,
                        color: Colors.white,
                        backgroundColor: const Color(0xFF293E68),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(top: 6, bottom: 28),
                          child: SizedBox(
                            width: double.infinity,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 450),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: buildPageContent(),
                            ),
                          ),
                        ),
                      ),
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
    // Every search, refresh, or location request shows the loading card.
    if (isLoading) {
      return buildLoadingState();
    }

    // Show the large error card only when no weather data exists.
    if (errorMessage != null && weatherData == null) {
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
            'Detecting the latest conditions for '
            '${cityController.text.trim().isEmpty ? 'your location' : cityController.text.trim()}',
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
            textAlign: TextAlign.center,
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
    return Column(
      key: const ValueKey('weather'),
      children: [
        CurrentWeatherCard(
          weatherData: weatherData!,
          fallbackCity: cityController.text,
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
}
