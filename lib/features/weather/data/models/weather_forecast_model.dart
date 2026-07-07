class WeatherForecastModel {
  final String? cod;
  final int? message;
  final int? count;
  final List<ForecastItem> forecastList;
  final City? city;

  const WeatherForecastModel({
    this.cod,
    this.message,
    this.count,
    required this.forecastList,
    this.city,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      cod: json['cod']?.toString(),
      message: (json['message'] as num?)?.toInt(),
      count: (json['cnt'] as num?)?.toInt(),
      forecastList: (json['list'] as List<dynamic>? ?? [])
          .map((item) => ForecastItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      city: json['city'] != null
          ? City.fromJson(json['city'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ForecastItem {
  final int? dateTime;
  final MainWeather? main;
  final List<WeatherCondition> weather;
  final Clouds? clouds;
  final Wind? wind;
  final int? visibility;
  final double? probabilityOfPrecipitation;
  final Sys? sys;
  final String? dateTimeText;
  final Rain? rain;

  const ForecastItem({
    this.dateTime,
    this.main,
    required this.weather,
    this.clouds,
    this.wind,
    this.visibility,
    this.probabilityOfPrecipitation,
    this.sys,
    this.dateTimeText,
    this.rain,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dateTime: (json['dt'] as num?)?.toInt(),
      main: json['main'] != null
          ? MainWeather.fromJson(json['main'] as Map<String, dynamic>)
          : null,
      weather: (json['weather'] as List<dynamic>? ?? [])
          .map(
            (item) => WeatherCondition.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      clouds: json['clouds'] != null
          ? Clouds.fromJson(json['clouds'] as Map<String, dynamic>)
          : null,
      wind: json['wind'] != null
          ? Wind.fromJson(json['wind'] as Map<String, dynamic>)
          : null,
      visibility: (json['visibility'] as num?)?.toInt(),
      probabilityOfPrecipitation: (json['pop'] as num?)?.toDouble(),
      sys: json['sys'] != null
          ? Sys.fromJson(json['sys'] as Map<String, dynamic>)
          : null,
      dateTimeText: json['dt_txt']?.toString(),
      rain: json['rain'] != null
          ? Rain.fromJson(json['rain'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MainWeather {
  final double? temperature;
  final double? feelsLike;
  final double? minimumTemperature;
  final double? maximumTemperature;
  final int? pressure;
  final int? seaLevel;
  final int? groundLevel;
  final int? humidity;
  final double? temperatureKf;
  final double? dewPoint;

  const MainWeather({
    this.temperature,
    this.feelsLike,
    this.minimumTemperature,
    this.maximumTemperature,
    this.pressure,
    this.seaLevel,
    this.groundLevel,
    this.humidity,
    this.temperatureKf,
    this.dewPoint,
  });

  factory MainWeather.fromJson(Map<String, dynamic> json) {
    return MainWeather(
      temperature: (json['temp'] as num?)?.toDouble(),
      feelsLike: (json['feels_like'] as num?)?.toDouble(),
      minimumTemperature: (json['temp_min'] as num?)?.toDouble(),
      maximumTemperature: (json['temp_max'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toInt(),
      seaLevel: (json['sea_level'] as num?)?.toInt(),
      groundLevel: (json['grnd_level'] as num?)?.toInt(),
      humidity: (json['humidity'] as num?)?.toInt(),
      temperatureKf: (json['temp_kf'] as num?)?.toDouble(),
      dewPoint: (json['dew_point'] as num?)?.toDouble(),
    );
  }
}

class WeatherCondition {
  final int? id;
  final String? main;
  final String? description;
  final String? icon;

  const WeatherCondition({this.id, this.main, this.description, this.icon});

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      id: (json['id'] as num?)?.toInt(),
      main: json['main']?.toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}

class Clouds {
  final int? percentage;

  const Clouds({this.percentage});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(percentage: (json['all'] as num?)?.toInt());
  }
}

class Wind {
  final double? speed;
  final int? degree;
  final double? gust;

  const Wind({this.speed, this.degree, this.gust});

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: (json['speed'] as num?)?.toDouble(),
      degree: (json['deg'] as num?)?.toInt(),
      gust: (json['gust'] as num?)?.toDouble(),
    );
  }
}

class Sys {
  final String? partOfDay;

  const Sys({this.partOfDay});

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(partOfDay: json['pod']?.toString());
  }
}

class Rain {
  final double? threeHourVolume;

  const Rain({this.threeHourVolume});

  factory Rain.fromJson(Map<String, dynamic> json) {
    return Rain(threeHourVolume: (json['3h'] as num?)?.toDouble());
  }
}

class City {
  final int? id;
  final String? name;
  final Coordinates? coordinates;
  final String? country;
  final int? population;
  final int? timezone;
  final int? sunrise;
  final int? sunset;

  const City({
    this.id,
    this.name,
    this.coordinates,
    this.country,
    this.population,
    this.timezone,
    this.sunrise,
    this.sunset,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      coordinates: json['coord'] != null
          ? Coordinates.fromJson(json['coord'] as Map<String, dynamic>)
          : null,
      country: json['country']?.toString(),
      population: (json['population'] as num?)?.toInt(),
      timezone: (json['timezone'] as num?)?.toInt(),
      sunrise: (json['sunrise'] as num?)?.toInt(),
      sunset: (json['sunset'] as num?)?.toInt(),
    );
  }
}

class Coordinates {
  final double? latitude;
  final double? longitude;

  const Coordinates({this.latitude, this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['lat'] as num?)?.toDouble(),
      longitude: (json['lon'] as num?)?.toDouble(),
    );
  }
}
