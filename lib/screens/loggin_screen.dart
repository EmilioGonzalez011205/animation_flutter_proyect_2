import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LogginScreen extends StatefulWidget {
  const LogginScreen({super.key});

  @override
  State<LogginScreen> createState() => _LogginScreenState();
}

class _LogginScreenState extends State<LogginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Animaciones Rive
  StateMachineController? controller;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMINumber? numLook;

  // Focus
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  // Timer para detener mirada
  Timer? _typingDebounce;

  // Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Errores
  String? emailError;
  String? passError;

  // Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  String? firstPasswordError(String pass) {
    if (pass.isEmpty) return 'La contraseña no puede estar vacía';
    if (pass.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(pass)) return 'Debe tener una mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(pass)) return 'Debe tener una minúscula';
    if (!RegExp(r'\d').hasMatch(pass)) return 'Debe tener un número';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(pass)) return 'Debe tener un carácter especial';
    return null; // Todo ok
  }

  Future<void> _onLogin() async {
    //Normalizar estado antes de validar
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    isChecking?.change(false);
    isHandsUp?.change(false);
    numLook?.value = 50.0;

    setState(() => _isLoading = true);

    //Esperar un frame para que Rive actualice el estado (importante)
    await Future.delayed(Duration.zero);
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    final eError = (email.isNotEmpty && !isValidEmail(email))
        ? 'Email no válido'
        : null;
    final pError = firstPasswordError(pass);

    setState(() {
      emailError = eError;
      passError = pError;
    });

    //Simular carga (círculo)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    //Disparar trigger después del "loading" (primer tap)
    await Future.delayed(const Duration(milliseconds: 100));

    if (eError == null && pError == null) {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }
  }

  @override
  void initState() {
    super.initState();

    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        isHandsUp?.change(false);
        numLook?.value = 50.0;
      }
    });

    passFocus.addListener(() {
      isHandsUp?.change(passFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: size.width,
                child: RiveAnimation.asset(
                  'Assets/animated_login_character.riv',
                  stateMachines: ['Login Machine'],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                        artboard, 'Login Machine');
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    numLook = controller!.findSMI('numLook');
                  },
                ),
              ),
              const SizedBox(height: 10),
              // EMAIL
              TextField(
                focusNode: emailFocus,
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  if (isChecking == null || numLook == null) return;

                  // Oso "chismoso" mirando mientras escribes
                  isChecking!.change(true);

                  // Movimiento suave de la mirada (0 a 100)
                  final look = (value.length / 30 * 100).clamp(0.0, 100.0);
                  numLook!.value = look;

                  // Debounce: si deja de escribir 2s, el oso deja de mirar
                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(const Duration(seconds: 2), () {
                    if (mounted) isChecking!.change(false);
                  });

                  // Validación reactiva del email
                  final trimmed = value.trim();
                  if (trimmed.isEmpty) {
                    setState(() => emailError = null);
                  } else if (!isValidEmail(trimmed)) {
                    setState(() => emailError = 'Email no válido');
                  } else {
                    setState(() => emailError = null);
                  }
                },
                decoration: InputDecoration(
                  errorText: emailError,
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // PASSWORD
              TextField(
                controller: passCtrl,
                focusNode: passFocus,
                obscureText: _obscurePassword,
                onChanged: (value) {
                  // Validación dinámica de la contraseña
                  setState(() => passError = firstPasswordError(value));

                  // Si el oso tiene las manos abajo, las sube al escribir
                  if (isHandsUp != null && passFocus.hasFocus) {
                    isHandsUp!.change(true);
                  }

                  // Reinicia el temporizador cada vez que se escribe algo
                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(const Duration(seconds: 1), () {
                    // Si después de 1s sigue enfocado el campo y no está escribiendo
                    // el oso baja las manos.
                    if (mounted && passFocus.hasFocus) {
                      isHandsUp?.change(false); 
                    }
                  });
                },
                decoration: InputDecoration(
                  errorText: passError,
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
              const SizedBox(height: 10),
              SizedBox(
                width: 375,
                child: Text(
                  'Olvidé mi contraseña',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // BOTÓN LOGIN
              SizedBox(
                width: 375,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              // REGISTRO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta?'),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Expresión regular: Es como un buscador que encuentra patrones en un texto.
//Foco: Es una expresión para indicar cuando le damos click a algo.
//Hover: Es una expresión para indicar cuando pasamos el mouse sobre algo.
//Regex: REGular EXpression 
//Clamp: En programación es limitar un valor dentro de un rango específico, en la vida real,
// es como un tope o límite que evita que algo se salga de ciertos parámetros establecidos.}
//Clamp se traduce como: "abrazadera"