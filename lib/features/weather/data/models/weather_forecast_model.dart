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
          .map(
            (item) =>
                ForecastItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      city: json['city'] != null
          ? City.fromJson(Map<String, dynamic>.from(json['city'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'message': message,
      'cnt': count,
      'list': forecastList.map((item) => item.toJson()).toList(),
      'city': city?.toJson(),
    };
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
          ? MainWeather.fromJson(Map<String, dynamic>.from(json['main'] as Map))
          : null,
      weather: (json['weather'] as List<dynamic>? ?? [])
          .map(
            (item) => WeatherCondition.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      clouds: json['clouds'] != null
          ? Clouds.fromJson(Map<String, dynamic>.from(json['clouds'] as Map))
          : null,
      wind: json['wind'] != null
          ? Wind.fromJson(Map<String, dynamic>.from(json['wind'] as Map))
          : null,
      visibility: (json['visibility'] as num?)?.toInt(),
      probabilityOfPrecipitation: (json['pop'] as num?)?.toDouble(),
      sys: json['sys'] != null
          ? Sys.fromJson(Map<String, dynamic>.from(json['sys'] as Map))
          : null,
      dateTimeText: json['dt_txt']?.toString(),
      rain: json['rain'] != null
          ? Rain.fromJson(Map<String, dynamic>.from(json['rain'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime,
      'main': main?.toJson(),
      'weather': weather.map((item) => item.toJson()).toList(),
      'clouds': clouds?.toJson(),
      'wind': wind?.toJson(),
      'visibility': visibility,
      'pop': probabilityOfPrecipitation,
      'sys': sys?.toJson(),
      'dt_txt': dateTimeText,
      'rain': rain?.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'temp': temperature,
      'feels_like': feelsLike,
      'temp_min': minimumTemperature,
      'temp_max': maximumTemperature,
      'pressure': pressure,
      'sea_level': seaLevel,
      'grnd_level': groundLevel,
      'humidity': humidity,
      'temp_kf': temperatureKf,
      'dew_point': dewPoint,
    };
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

  Map<String, dynamic> toJson() {
    return {'id': id, 'main': main, 'description': description, 'icon': icon};
  }
}

class Clouds {
  final int? percentage;

  const Clouds({this.percentage});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(percentage: (json['all'] as num?)?.toInt());
  }

  Map<String, dynamic> toJson() {
    return {'all': percentage};
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

  Map<String, dynamic> toJson() {
    return {'speed': speed, 'deg': degree, 'gust': gust};
  }
}

class Sys {
  final String? partOfDay;

  const Sys({this.partOfDay});

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(partOfDay: json['pod']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'pod': partOfDay};
  }
}

class Rain {
  final double? threeHourVolume;

  const Rain({this.threeHourVolume});

  factory Rain.fromJson(Map<String, dynamic> json) {
    return Rain(threeHourVolume: (json['3h'] as num?)?.toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'3h': threeHourVolume};
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
          ? Coordinates.fromJson(
              Map<String, dynamic>.from(json['coord'] as Map),
            )
          : null,
      country: json['country']?.toString(),
      population: (json['population'] as num?)?.toInt(),
      timezone: (json['timezone'] as num?)?.toInt(),
      sunrise: (json['sunrise'] as num?)?.toInt(),
      sunset: (json['sunset'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coord': coordinates?.toJson(),
      'country': country,
      'population': population,
      'timezone': timezone,
      'sunrise': sunrise,
      'sunset': sunset,
    };
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

  Map<String, dynamic> toJson() {
    return {'lat': latitude, 'lon': longitude};
  }
}
