import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weather_ball/src/ui/screen/base/animated_state.dart';

class AnimatedTextWidget extends StatefulWidget {
  final String textBefore;
  final double maxValue;

  AnimatedTextWidget({this.textBefore, this.maxValue, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedTextWidgetState();
}

class _AnimatedTextWidgetState extends AnimatedState<AnimatedTextWidget> {
  double _value = 0;

  @override
  void initState() {
    super.initState();
    animateTween(start: 0, end: widget.maxValue, duration: 2000);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.textBefore} ${_value.toStringAsFixed(0)}%",
      textDirection: TextDirection.ltr,
      style: Theme.of(context).textTheme.headline6,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onAnimatedValue(double value) {
    setState(() {
      _value = value;
    });
  }
}
