import 'package:flutter/material.dart';

ThemeData theme() {
  Color secondaryColor = Colors.orange;
  Color primaryColor = Colors.blue.withOpacity(.8);
  return ThemeData(
      primaryColor: primaryColor,
      secondaryHeaderColor: secondaryColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      textTheme: TextTheme(
          headline1: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
          headline2: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14.5),
          bodyText1: TextStyle(
              color: Colors.black.withOpacity(.8),
              fontWeight: FontWeight.w500,
              fontSize: 12),
          button: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        hintStyle: TextStyle(
            color: Colors.black.withOpacity(.4),
            fontWeight: FontWeight.w500,
            fontSize: 10),
      ));
}
