import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:weather_ball/src/blocs/application_bloc.dart';
import 'package:weather_ball/src/resources/application_localization_delegate.dart';
import 'package:weather_ball/src/resources/config/application_config.dart';
import 'package:weather_ball/src/ui/screen/splash_screen.dart';
import 'package:weather_ball/src/ui/screen/weather_ball_screen.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: <String, WidgetBuilder>{
          '/HomeScreen': (BuildContext context) => new HomeScreen()
        },
      ),
    );

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new SplashScreen(
//         seconds: 10,
//         navigateAfterSeconds: new Myhome(),
//         image: new Image.asset('assets/images/splash.jpg'),
//         backgroundColor: Colors.white,
//         photoSize: 100.0,
//         loaderColor: Colors.red);
//   }
// }

class HomeScreen extends StatelessWidget {
  HomeScreen() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _configureLogger();
    applicationBloc.loadSavedUnit();
    applicationBloc.loadSavedRefreshTime();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: WeatherMainScreen(),
      home: WeatherBallScreen(),
      debugShowCheckedModeBanner: false,
      theme: _configureThemeData(),
      localizationsDelegates: [
        const ApplicationLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en"),
        // const Locale("pl"),
      ],
    );
  }

  _configureLogger() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      if (ApplicationConfig.isDebug) {
        print(
            '[${rec.level.name}][${rec.time}][${rec.loggerName}]: ${rec.message}');
      }
    });
  }

  ThemeData _configureThemeData() {
    return ThemeData(
      textTheme: TextTheme(
        headline5: TextStyle(fontSize: 60.0, color: Colors.white),
        headline6: TextStyle(fontSize: 35, color: Colors.white),
        subtitle2: TextStyle(fontSize: 20, color: Colors.white),
        bodyText2: TextStyle(fontSize: 15, color: Colors.white),
        bodyText1: TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}
