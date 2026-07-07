abstract class WeatherEvent {
  const WeatherEvent();
}

class FetchCurrentLocationWeather extends WeatherEvent {
  const FetchCurrentLocationWeather();
}

class SearchWeatherByCity extends WeatherEvent {
  const SearchWeatherByCity(this.city);

  final String city;
}

class RefreshWeather extends WeatherEvent {
  const RefreshWeather();
}
