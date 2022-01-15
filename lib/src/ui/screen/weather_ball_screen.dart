import 'package:flutter/material.dart';
import 'package:weather_ball/src/models/internal/overflow_menu_element.dart';
import 'package:weather_ball/src/resources/application_localization.dart';
import 'package:weather_ball/src/resources/config/application_colors.dart';
import 'package:weather_ball/src/ui/screen/about_screen.dart';
import 'package:weather_ball/src/ui/screen/settings_screen.dart';
import 'package:weather_ball/src/ui/widget/weather_ball_widget.dart';

class WeatherBallScreen extends StatelessWidget {
  List<PopupMenuElement> _getOverflowMenu(BuildContext context) {
    var applicationLocalization = ApplicationLocalization.of(context);
    List<PopupMenuElement> menuList = List();
    menuList.add(PopupMenuElement(
      key: Key("menu_overflow_settings"),
      title: applicationLocalization.getText("settings"),
    ));
    menuList.add(PopupMenuElement(
      key: Key("menu_overflow_about"),
      title: applicationLocalization.getText("about"),
    ));
    return menuList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            Container(
              key: Key("weather_ball_screen_container"),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/images/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: WeatherBallWidget(),
            ),
            new Positioned(
              //Place it at the top, and not use the entire screen
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                actions: <Widget>[
                  Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: ApplicationColors.nightStartColor,
                    ),
                    child: PopupMenuButton<PopupMenuElement>(
                      onSelected: (PopupMenuElement element) {
                        _onMenuElementClicked(element, context);
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      itemBuilder: (BuildContext context) {
                        return _getOverflowMenu(context)
                            .map((PopupMenuElement element) {
                          return PopupMenuItem<PopupMenuElement>(
                              value: element,
                              child: Text(element.title,
                                  style: TextStyle(color: Colors.white)));
                        }).toList();
                      },
                    ),
                  )
                ],
                backgroundColor: Colors.transparent, //No more green
                elevation: 0.0, //Shadow gone
              ),
            ),
          ],
        ));
  }

  void _onMenuElementClicked(PopupMenuElement value, BuildContext context) {
    if (value.key == Key("menu_overflow_settings")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
    }
    if (value.key == Key("menu_overflow_about")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AboutScreen()),
      );
    }
  }
}
