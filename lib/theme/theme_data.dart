import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 13, 135, 236)),
    fontFamily: 'Roboto',
    useMaterial3: true,
    appBarTheme:  AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 164, 187, 198),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: const Color.fromARGB(255, 13, 13, 13),
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  );
}