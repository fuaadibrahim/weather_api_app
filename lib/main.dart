import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/weather/data/services/location_services.dart';
import 'features/weather/data/services/network_service.dart';
import 'features/weather/data/services/weather_local_storage.dart';
import 'features/weather/data/services/weather_service.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/weather/presentation/bloc/weather_event.dart';
import 'features/weather/presentation/screens/weather_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final Box<dynamic> weatherBox = await Hive.openBox<dynamic>('weather_cache');

  runApp(
    BlocProvider(
      create: (_) => WeatherBloc(
        weatherService: WeatherService(),
        locationServices: LocationServices(),
        weatherLocalStorage: WeatherLocalStorage(weatherBox),
        networkService: NetworkService(),
      )..add(const InitializeWeather()),
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
      scrollBehavior: const AppScrollBehavior(),
      home: const WeatherScreen(),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
