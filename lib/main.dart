import 'package:digitalbank/pages/login.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(CupertinoApp(
    title: 'Crucian Bank',
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
    theme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF61D38D),
    ),
  ));
}

