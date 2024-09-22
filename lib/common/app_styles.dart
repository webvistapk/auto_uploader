import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    // fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.white,
  );

  static const InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hoverColor: Colors.transparent, // Remove the grey hover effect
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(
        vertical: 16.0, horizontal: 12.0), // Adjust padding
    floatingLabelBehavior:
        FloatingLabelBehavior.auto, // Adjusts label behavior when focused
    floatingLabelStyle: TextStyle(
      color: Colors.grey,
      fontSize: 20.0,
    ),
    labelStyle: TextStyle(color: Colors.grey),
  );
}
