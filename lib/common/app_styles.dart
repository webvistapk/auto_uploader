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

  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hoverColor: Colors.transparent, // Remove the grey hover effect
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 16.0,
      horizontal: 12.0,
    ), // Adjust padding
    floatingLabelBehavior:
        FloatingLabelBehavior.auto, // Keep the label inside until focused
    floatingLabelStyle: const TextStyle(
      color: Colors.blueAccent, // Custom color when label floats
      fontSize: 18.0, // Slightly reduce font size for professional look
      fontWeight: FontWeight.bold, // Make it more noticeable
    ),
    labelStyle: const TextStyle(
      color: Colors.grey, // Normal color when label is not floating
      fontSize: 16.0,
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(
        color: Colors.blueAccent, // Custom color for the focused border
        width: 2.0, // Slightly thicker border when focused
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.5), // Subtle border when not focused
        width: 1.5,
      ),
    ),
    labelText: 'Your Label Here', // Add a label text
  );
}
