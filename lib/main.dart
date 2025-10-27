import 'package:animation_flutter_proyect_2/screens/loggin_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const LogginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

