import 'dart:async';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather_ball/src/blocs/application_bloc.dart';
import 'package:weather_ball/src/blocs/base_bloc.dart';
import 'package:weather_ball/src/models/internal/application._error.dart';
import 'package:weather_ball/src/models/internal/geo_postion.dart';
import 'package:weather_ball/src/models/remote/weather_response.dart';
import 'package:weather_ball/src/utils/date_time_helper.dart';

class WeatherBloc extends BaseBloc {
  final weatherSubject = BehaviorSubject<WeatherResponse>();
  final _logger = new Logger("WeatherBloc");
  int lastRequestTime = 0;
  Timer _timer;

  fetchWeatherForUserLocation() async {
    _logger.log(Level.FINE, "Fetch weather for user location");

    GeoPosition geoPosition = await getPosition();
    if (geoPosition != null) {
      fetchWeather(geoPosition.lat, geoPosition.long);
    } else {
      _logger.log(
          Level.WARNING, "Fetch weather failed because location not selected");
      weatherSubject.sink.add(WeatherResponse.withErrorCode(
          ApplicationError.locationNotSelectedError));
    }
  }

  fetchWeather(double latitude, double longitude) async {
    _logger.log(Level.FINE, "Fetch weather");
    lastRequestTime = DateTimeHelper.getCurrentTime();
    WeatherResponse weatherResponse =
        await weatherRemoteRepository.fetchWeather(latitude, longitude);
    if (weatherResponse.errorCode == null) {
      weatherLocalRepository.saveWeather(weatherResponse);
    } else {
      _logger.info("Selected weather from storage");
      WeatherResponse weatherResponseStorage =
          await weatherLocalRepository.getWeather();
      if (weatherResponseStorage != null) {
        weatherResponse = weatherResponseStorage;
      }
    }
    applicationBloc.saveLastRefreshTime(DateTimeHelper.getCurrentTime());
    weatherSubject.sink.add(weatherResponse);
  }

  setupTimer() {
    _logger.log(Level.FINE, "Setup timer");
    if (_timer == null) {
      var duration = Duration(milliseconds: applicationBloc.refreshTime);
      _timer = new Timer(duration, handleTimerTimeout);
    } else {
      _logger.warning(
          "Could not setup new timer, because previous isn't finished");
    }
  }

  handleTimerTimeout() {
    _logger.log(Level.FINE, "handle timer timeout");
    _timer = null;
    setupTimer();
    fetchWeatherForUserLocation();
  }

  dispose() {
    _logger.log(Level.FINE, "Dispose");
    weatherSubject.close();
  }
}

final bloc = WeatherBloc();
