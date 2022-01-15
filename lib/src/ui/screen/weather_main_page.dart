import 'package:flutter/widgets.dart';
import 'package:weather_ball/src/models/remote/weather_response.dart';
import 'package:weather_ball/src/ui/widget/weather_current_widget.dart';

class WeatherMainPage extends StatelessWidget {
  final WeatherResponse weatherResponse;

  const WeatherMainPage({Key key, this.weatherResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WeatherCurrentWidget(
      key: Key("weather_main_page_current_weather"),
      weatherResponse: weatherResponse,
    );
  }
}
