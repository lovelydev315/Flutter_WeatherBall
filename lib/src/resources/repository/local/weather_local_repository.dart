import 'package:weather_ball/src/models/internal/geo_postion.dart';
import 'package:weather_ball/src/models/remote/weather_forecast_list_response.dart';
import 'package:weather_ball/src/models/remote/weather_response.dart';
import 'package:weather_ball/src/resources/repository/local/storage_manager.dart';

class WeatherLocalRepository {
  final StorageManager _storageManager = StorageManager();

  static final WeatherLocalRepository _instance =
      WeatherLocalRepository._internal();

  WeatherLocalRepository._internal();

  factory WeatherLocalRepository() {
    return _instance;
  }

  void saveLocation(GeoPosition geoPosition) async {
    await _storageManager.saveLocation(geoPosition);
  }

  Future<GeoPosition> getLocation() async {
    return await _storageManager.getLocation();
  }

  void saveWeather(WeatherResponse response) async {
    await _storageManager.saveWeather(response);
  }

  Future<WeatherResponse> getWeather() async {
    return await _storageManager.getWeather();
  }

  void saveWeatherForecast(WeatherForecastListResponse response) async {
    await _storageManager.saveWeatherForecast(response);
  }

  Future<WeatherForecastListResponse> getWeatherForecast() async {
    return await _storageManager.getWeatherForecast();
  }
}
