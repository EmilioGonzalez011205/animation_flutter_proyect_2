import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LogginScreen extends StatefulWidget {
  const LogginScreen({super.key});

  @override
  State<LogginScreen> createState() => _LogginScreenState();
}

class _LogginScreenState extends State<LogginScreen> {
  // Variable para controlar si se muestra la contraseña o no
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // Evita notch o cámaras frontales
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: size.width,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                ),
              ),
              const SizedBox(height: 10),
              // Campo Email
              SizedBox(
                width: 375,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Campo Password con icono de mostrar/ocultar
              SizedBox(
                width: 375,
                child: TextField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}