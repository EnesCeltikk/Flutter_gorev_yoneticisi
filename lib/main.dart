import 'package:flutter/material.dart';


import 'home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Flutter ToDo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Itim',
      ),
      home: SafeArea(
        child: HomePage(),
      ),
    );
  }
}

