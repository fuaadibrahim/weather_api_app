import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/weather/data/services/location_services.dart';
import 'features/weather/data/services/weather_service.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/weather/presentation/bloc/weather_event.dart';
import 'features/weather/presentation/screens/weather_screen.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => WeatherBloc(
        weatherService: WeatherService(),
        locationServices: LocationServices(),
      )..add(const FetchCurrentLocationWeather()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(useMaterial3: true),
      home: const WeatherScreen(),
    );
  }
}
