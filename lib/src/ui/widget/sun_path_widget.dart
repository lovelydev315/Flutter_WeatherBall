import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weather_ball/src/resources/weather_helper.dart';
import 'package:weather_ball/src/ui/screen/base/animated_state.dart';
import 'package:weather_ball/src/utils/date_time_helper.dart';

class SunPathWidget extends StatefulWidget {
  final int sunrise;
  final int sunset;

  const SunPathWidget({Key key, this.sunrise, this.sunset}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SunPathWidgetState();
}

class _SunPathWidgetState extends AnimatedState<SunPathWidget> {
  double _fraction = 0.0;

  @override
  void initState() {
    super.initState();
    animateTween(duration: 2000);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        key: Key("sun_path_widget_sized_box"),
        width: 300,
        height: 150,
        child: CustomPaint(
          key: Key("sun_path_widget_custom_paint"),
          painter: _SunPathPainter(widget.sunrise, widget.sunset, _fraction),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onAnimatedValue(double value) {
    setState(() {
      _fraction = value;
    });
  }
}

class _SunPathPainter extends CustomPainter {
  final double fraction;
  final double pi = 3.14159;
  final int dayAsMs = 86400000;
  final int sunrise;
  final int sunset;

  _SunPathPainter(this.sunrise, this.sunset, this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    Paint arcPaint = _getArcPaint();
    Rect rect = Rect.fromLTWH(0, 5, size.width, size.height * 2);
    canvas.drawArc(rect, 0, -pi, false, arcPaint);
    Paint circlePaint = _getCirclePaint();
    canvas.drawCircle(_getPosition(fraction), 10, circlePaint);
  }

  @override
  bool shouldRepaint(_SunPathPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }

  Paint _getArcPaint() {
    Paint paint = Paint();
    paint..color = Colors.white;
    paint..strokeWidth = 2;
    paint..style = PaintingStyle.stroke;
    return paint;
  }

  Paint _getCirclePaint() {
    Paint circlePaint = Paint();
    int mode = WeatherHelper.getDayModeFromSunriseSunset(sunrise, sunset);
    if (mode == 0) {
      circlePaint..color = Colors.yellow;
    } else {
      circlePaint..color = Colors.white;
    }
    return circlePaint;
  }

  Offset _getPosition(fraction) {
    int now = DateTimeHelper.getCurrentTime();
    int mode = WeatherHelper.getDayModeFromSunriseSunset(sunrise, sunset);
    double difference = 0;
    if (mode == 0) {
      difference = (now - sunrise) / (sunset - sunrise);
    } else if (mode == 1) {
      DateTime nextSunrise =
          DateTime.fromMillisecondsSinceEpoch(sunrise + dayAsMs);
      difference =
          (now - sunset) / (nextSunrise.millisecondsSinceEpoch - sunset);
    } else if (mode == -1) {
      DateTime previousSunset =
          DateTime.fromMillisecondsSinceEpoch(sunset - dayAsMs);
      difference = 1 -
          ((sunrise - now) / (sunrise - previousSunset.millisecondsSinceEpoch));
    }

    var x = 150 * cos((1 + difference * fraction) * pi) + 150;
    var y = 145 * sin((1 + difference * fraction) * pi) + 150;
    return Offset(x, y);
  }
}
