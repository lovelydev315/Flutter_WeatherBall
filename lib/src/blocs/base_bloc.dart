import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:weather_ball/src/models/internal/geo_postion.dart';
import 'package:weather_ball/src/resources/location_manager.dart';
import 'package:weather_ball/src/resources/repository/local/weather_local_repository.dart';
import 'package:weather_ball/src/resources/repository/remote/weather_remote_repository.dart';

abstract class BaseBloc {
  @protected
  final weatherRemoteRepository = WeatherRemoteRepository();
  @protected
  final weatherLocalRepository = WeatherLocalRepository();
  @protected
  final locationManager = LocationManager();
  final Logger _logger = Logger("BaseBloc");

  Future<GeoPosition> getPosition() async {
    try {
      var positionOptional = await locationManager.getLocation();
      if (positionOptional.isPresent) {
        _logger.fine("Position is present!");
        var position = positionOptional.value;
        GeoPosition geoPosition = GeoPosition.fromPosition(position);
        weatherLocalRepository.saveLocation(geoPosition);
        return geoPosition;
      } else {
        _logger.fine("Position is not present!");
        return weatherLocalRepository.getLocation();
      }
    } catch (exc, stackTrace) {
      _logger.warning("Exception: $exc in stackTrace: $stackTrace");
      return null;
    }
  }

  void setupTimer();

  void handleTimerTimeout();

  void dispose();
}
