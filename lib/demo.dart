import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/login_screen.dart';

class SessionListener extends StatefulWidget {
  const SessionListener({super.key});

  @override
  State<SessionListener> createState() => _SessionListenerState();
}

class _SessionListenerState extends State<SessionListener> {
  Timer? _timer;
  _startTimer() {
    print("Timer Reset");
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    _timer = Timer(Duration(seconds: 30), () {
      print("Elasped");
      TimerOut();
    });
  }

  TimerOut() {
    print("Timer out");
    //Navigae to Sign in Screen
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoDialogRoute(builder: (_) => LoginScreen(), context: context),
        (route) => false);
  }

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _startTimer(),
      behavior: HitTestBehavior.translucent,
      child: Container(),
    );
  }
}
