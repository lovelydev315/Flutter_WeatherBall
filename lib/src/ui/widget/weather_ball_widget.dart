import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:weather_ball/src/blocs/weather_forecast_bloc.dart';
import 'package:weather_ball/src/models/remote/weather_forecast_list_response.dart';
import 'package:weather_ball/src/models/remote/weather_forecast_response.dart';
import 'package:weather_ball/src/resources/weather_helper.dart';
import 'package:weather_ball/src/ui/screen/weather_main_screen.dart';
import 'package:weather_ball/src/ui/widget/widget_helper.dart';
import 'package:weather_ball/src/blocs/application_bloc.dart';

class WeatherBallWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WeatherBallWidgetState();
}

class WeatherBallWidgetState extends State<WeatherBallWidget> {
  Logger _logger = Logger("WeatherBallWidgetState");
  Image image;
  Color rainColor;
  bool isRainColor = false;
  bool isRain = false;
  bool _pressAttention = true;
  String convertedDateTime;

  @override
  void initState() {
    super.initState();
    bloc.setupTimer();
    bloc.fetchWeatherForecastForUserLocation();
    currentDateTime();
    setState(() {
      _pressAttention = true;
      isRainColor = false;
    });
    Timer.periodic(
        Duration(milliseconds: 500), (Timer t) => isRainColorManager());

    Timer.periodic(
      Duration(minutes: 1),
      (Timer t) => setState(() {
        currentDateTime();
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void isRainColorManager() {
    if (isRainColor == false) {
      setState(() {
        rainColor = Colors.grey;
        isRainColor = true;
      });
    } else {
      setState(() {
        rainColor = Colors.blueGrey;
        isRainColor = false;
      });
    }
  }

  void weatherBallRed() {
    if (isRain == false) {
      image = Image(
          alignment: Alignment.bottomCenter,
          image: AssetImage("assets/images/weather_ball_red.png"),
          height: MediaQuery.of(context).size.height * 0.7);
      setState(() {
        isRain = true;
      });
    } else {
      image = Image(
          alignment: Alignment.bottomCenter,
          image: AssetImage("assets/images/weather_ball_red_rain.png"),
          height: MediaQuery.of(context).size.height * 0.7);
      setState(() {
        isRain = false;
      });
    }
  }

  void weatherBallBlue() {
    if (isRain == false) {
      setState(() {
        image = Image(
            alignment: Alignment.bottomCenter,
            image: AssetImage("assets/images/weather_ball_blue.png"),
            height: MediaQuery.of(context).size.height * 0.7);
        isRain = true;
      });
    } else {
      setState(() {
        image = Image(
            alignment: Alignment.bottomCenter,
            image: AssetImage("assets/images/weather_ball_blue_rain.png"),
            height: MediaQuery.of(context).size.height * 0.7);
        isRain = false;
      });
    }
  }

  void weatherBallYellow() {
    if (isRain == false) {
      setState(() {
        image = Image(
            alignment: Alignment.bottomCenter,
            image: AssetImage("assets/images/weather_ball_yellow.png"),
            height: MediaQuery.of(context).size.height * 0.7);
        isRain = true;
      });
    } else {
      setState(() {
        image = Image(
            alignment: Alignment.bottomCenter,
            image: AssetImage("assets/images/weather_ball_yellow_rain.png"),
            height: MediaQuery.of(context).size.height * 0.7);
        isRain = false;
      });
    }
  }

  void _updateUI(List<WeatherForecastResponse> forecastData) {
    try {
      if (forecastData != null) {
        if (forecastData[0].mainWeatherData.temp <
            forecastData[8].mainWeatherData.temp) {
          if (forecastData[8].precipitation != null &&
              forecastData[8].precipitation > 30.0) {
            Timer.periodic(
                Duration(milliseconds: 500), (Timer t) => weatherBallRed());
          } else {
            image = Image(
                alignment: Alignment.bottomCenter,
                image: AssetImage("assets/images/weather_ball_red.png"),
                height: MediaQuery.of(context).size.height * 0.7);
          }
        } else if (forecastData[0].mainWeatherData.temp >
            forecastData[8].mainWeatherData.temp) {
          if (forecastData[8].precipitation != null &&
              forecastData[8].precipitation > 30.0) {
            Timer.periodic(
                Duration(milliseconds: 500), (Timer t) => weatherBallBlue());
          } else {
            image = Image(
                alignment: Alignment.bottomCenter,
                image: AssetImage("assets/images/weather_ball_blue.png"),
                height: MediaQuery.of(context).size.height * 0.7);
          }
        } else {
          if (forecastData[8].precipitation != null &&
              forecastData[8].precipitation > 30.0) {
            Timer.periodic(
                Duration(milliseconds: 500), (Timer t) => weatherBallYellow());
          } else {
            image = Image(
                alignment: Alignment.bottomCenter,
                image: AssetImage("assets/images/weather_ball_yellow.png"),
                height: MediaQuery.of(context).size.height * 0.7);
          }
        }
      } else {
        print("Forecast Data Error!");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.weatherForecastSubject.stream,
      builder: (context, AsyncSnapshot<WeatherForecastListResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.errorCode != null) {
            return WidgetHelper.buildErrorWidget(
                context: context,
                applicationError: snapshot.data.errorCode,
                voidCallback: () => bloc.fetchWeatherForecastForUserLocation(),
                withRetryButton: true);
          }
          _logger.fine("Build weather container");
          return buildWeatherBallContainer(snapshot);
        } else if (snapshot.hasError) {
          return WidgetHelper.buildErrorWidget(
              context: context,
              applicationError: snapshot.error,
              voidCallback: () => bloc.fetchWeatherForecastForUserLocation(),
              withRetryButton: true);
        }
        return WidgetHelper.buildProgressIndicator();
      },
    );
  }

  Widget buildWeatherBallContainer(
      AsyncSnapshot<WeatherForecastListResponse> snapshot) {
    var mq = MediaQuery.of(context).size;
    List<WeatherForecastResponse> forecastList = snapshot.data.list;
    _updateUI(forecastList);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: mq.height,
        width: mq.width,
        key: Key("weather_main_widget_container"),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: mq.width * 0.1,
              top: mq.height * 0.1,
              child: currentData(forecastList),
            ),
            Positioned(
              bottom: 0,
              left: 8,
              child: weatherBallDescription(),
            ),
            image != null
                ? Positioned(
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: mq.height * 0.65,
                      child: image,
                    ),
                  )
                : Text('error!')
          ],
        ),
      ),
    );
  }

  Widget weatherBallDescription() {
    var mq = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromRGBO(0, 0, 0, 0.8),
      ),
      height: mq.height * 0.55,
      width: mq.width * 0.4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: Colors.red),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  "When the weatherball ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  "is red higher ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text(
                  "temperature's ahead.",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  "When the weatherball ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  "is blue lower ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text(
                  "temperature is due.",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Container(
                  width: 70,
                  height: 20,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.yellow)),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  "Yellow light in weatherball ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  "means there'll be ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 27),
                child: Text(
                  "no change at all.",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: rainColor != null ? rainColor : Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  "When colors blink in ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  "agitation there's going ",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text(
                  "to be precipitation.",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget currentData(List<WeatherForecastResponse> forecastList) {
    return Container(
      padding: EdgeInsets.all(25.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                  WeatherHelper.getWeatherIcon(
                      forecastList[0].overallWeatherData[0].id),
                  width: 30,
                  height: 30),
              SizedBox(
                width: 30,
              ),
              Text(
                forecastList[0].overallWeatherData[0].main,
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Text(
                '${WeatherHelper.formatTemperature(temperature: forecastList[0].mainWeatherData.temp, metricUnits: applicationBloc.isMetricUnits())}',
                style: TextStyle(fontSize: 50, color: Colors.white),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                width: MediaQuery.of(context).copyWith().size.width * 0.3,
                child: RaisedButton(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _pressAttention
                          ? <Widget>[
                              FaIcon(FontAwesomeIcons.chartLine),
                              Text('Forecast'),
                            ]
                          : <Widget>[
                              SpinKitWave(
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ],
                    ),
                  ),
                  color: Colors.white24,
                  onPressed: () {
                    setState(() {
                      _pressAttention = !_pressAttention;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return WeatherMainScreen();
                        },
                      ),
                    );
                    setState(() {
                      _pressAttention = !_pressAttention;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            convertedDateTime,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void currentDateTime() {
    var now = new DateTime.now();
    convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString()}:${now.minute.toString()}";
  }
}
