import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
class LogginScreen extends StatefulWidget {
  const LogginScreen({super.key});

  @override
  State<LogginScreen> createState() => _LogginScreenState();
}

class _LogginScreenState extends State<LogginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Evita nudge o cámaras frontales
      body: 
        SafeArea(
          child: 
            Column(
                children: [
                  Expanded(child: RiveAnimation.asset('assets/animated_login_character.riv')),
                ],
      )),
    );
  }
}