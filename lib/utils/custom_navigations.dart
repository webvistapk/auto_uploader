import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

push(context, screen) {
  Navigator.push(
      context, PageTransition(child: screen, type: PageTransitionType.fade));
}

pushReplacement(context, screen) {
  Navigator.pushReplacement(
      context, PageTransition(child: screen, type: PageTransitionType.fade));
}

pushUntil(context, screen) {
  Navigator.pushAndRemoveUntil(context,
      CupertinoPageRoute(builder: (context) => screen), (route) => false);
}

pop(context) {
  Navigator.pop(context);
}
