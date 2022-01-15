import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weather_ball/src/models/internal/chart_data.dart';
import 'package:weather_ball/src/models/internal/weather_forecast_holder.dart';
import 'package:weather_ball/src/resources/application_localization.dart';
import 'package:weather_ball/src/resources/config/assets.dart';
import 'package:weather_ball/src/resources/weather_helper.dart';
import 'package:weather_ball/src/ui/screen/base/weather_forecast_base_page.dart';

class WeatherForecastRainPage extends WeatherForecastBasePage {
  WeatherForecastRainPage(
      WeatherForecastHolder holder, double width, double height)
      : super(holder: holder, width: width, height: height);

  @override
  Row getBottomRowWidget(BuildContext context) {
    return Row(
      key: Key("weather_forecast_rain_page_bottom_row"),
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  @override
  ChartData getChartData() {
    return super.holder.setupChartData(ChartDataType.rain, width, height);
  }

  @override
  String getIcon() {
    return Assets.iconRain;
  }

  @override
  RichText getPageSubtitleWidget(BuildContext context) {
    return RichText(
        key: Key("weather_forecast_rain_page_subtitle"),
        textDirection: TextDirection.ltr,
        text: TextSpan(children: [
          TextSpan(text: 'min ', style: Theme.of(context).textTheme.bodyText1),
          TextSpan(
              text: WeatherHelper.formatRain(holder.minRain),
              style: Theme.of(context).textTheme.subtitle2),
          TextSpan(
              text: '   max ', style: Theme.of(context).textTheme.bodyText1),
          TextSpan(
              text: WeatherHelper.formatRain(holder.maxRain),
              style: Theme.of(context).textTheme.subtitle2)
        ]));
  }

  @override
  String getTitleText(BuildContext context) {
    return ApplicationLocalization.of(context).getText("rain");
  }
}
