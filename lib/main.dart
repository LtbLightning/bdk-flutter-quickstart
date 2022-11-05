import 'package:bdk_flutter_quickstart/screens/home.dart';
import 'package:bdk_flutter_quickstart/styles/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BDK-FLUTTER TUTORIAL',
      theme: theme(),
      home: const Home(),
    );
  }
}
