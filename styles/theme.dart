import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
    textTheme: TextTheme(
      headline1: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
      headline2: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14.5),
      bodyText1: TextStyle(
          color: Colors.black.withOpacity(.8),
          fontWeight: FontWeight.w500,
          fontSize: 12),
    ),
  );
}


