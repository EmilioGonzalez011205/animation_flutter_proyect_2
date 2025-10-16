import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
//Importar librería para timer
import 'dart:async';

class LogginScreen extends StatefulWidget {
  const LogginScreen({super.key});

  @override
  State<LogginScreen> createState() => _LogginScreenState();
}

class _LogginScreenState extends State<LogginScreen> {
  // Variable para controlar si se muestra la contraseña o no
  bool _obscurePassword = true;
  

  //Cerebro de la lógica de las animaciones.
  StateMachineController? controller;
  // SMI = State Machine Input
  SMIBool? isChecking; //Activa el modo chismoso
  SMIBool? isHandsUp; //Se tapa los ojos
  SMITrigger? trigSuccess; //Se emociona
  SMITrigger? trigFail; //Se pone sad 

  //1.1) Focus Node (punto donde está el foco)
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  //3.2 Crear la variable timer para detener la mirada al dejar de teclear
  Timer? _typingDebounce;

  //4.1 Controllers; verfica o guarda la información que el usuario inserta.
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();


  //4.2 Errores para pintar o mostrar en la UI.
  String? emailError;
  String? passError;

  //4.3 Validadores 
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 Acción al botón
  void _onLogin(){
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
  

  //Recalcular rrores 
  final eError = isValidEmail(email) ? null : 'Email no válido';
  final pError = isValidPassword(pass) ? null : 
  'Mínimo 8 caracteres, 1 mayúsucla, 1 minúscula, 1 número y 1 caracterespecial';

// 4.5 Para avisar que hubo un cambio
  setState((){
    emailError = eError;
    passError = pError;
  });

  //4.6 Cerrar el teclado y bajar
FocusScope.of(context).unfocus();
_typingDebounce?.cancel();
isChecking?.change(false);
isHandsUp?.change(false);
numLook?.value = 50.0; // Mirada neutral


//4.7 Activar triggers
 if (eError == null && pError == null){
  trigSuccess?.fire();
 }
 else {
  trigFail?.fire();}
}


  //Variable para recorrido de la mirada
  SMINumber? numLook;

  //2.1) Listener (escuchar los cambios de foco; OYENTES o chismosos) 
  @override
  void initState() {
    super.initState();
    emailFocus.addListener((){
      if (emailFocus.hasFocus){
        //Manos abajo en gmail
        isHandsUp?.change(false);
        //Mirada neutral al enfocar email
        numLook?.value = 50.0;
      } 
    });

    passFocus.addListener((){
      //Manos arriba en password
      isHandsUp?.change(passFocus.hasFocus);
    });
  }


  @override
  Widget build(BuildContext context) {

    //1.4Liberación de recursos/limpieza de focos
    @override 
    void dispose() {
      emailCtrl.dispose();
      passCtrl.dispose();
      emailFocus.dispose();
      passFocus.dispose();
      _typingDebounce?.cancel();
      super.dispose();
    }

    // Obtener el tamaño de la pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.pink[50],
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
                  'Assets/animated_login_character.riv',
                  stateMachines: ['Login Machine'],
                  //Al iniciarse
                  onInit: (artboard){
                    controller= StateMachineController.fromArtboard(
                      artboard, 
                      'Login Machine',
                      );
                      //Verificar que todo está bien
                      if(controller ==null) return;
                      artboard.addController(controller!);
                      //Asignar las variables
                      isChecking = controller!.findSMI('isChecking');
                      isHandsUp = controller!.findSMI('isHandsUp');
                      trigSuccess = controller!.findSMI('trigSuccess');
                      trigFail = controller!.findSMI('trigFail');
                      //2.3Enlazar la variable con la animación
                      numLook = controller!.findSMI('numLook');
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Campo Email
              SizedBox(
                width: size.width,
                child: 
                //Email
                TextField(
                  //1.3 Asignas el focusnode al textfield
                  //llamas a la familia chismosa
                  focusNode: emailFocus,
                  //4.8 Enlazar controller a TextField
                  controller: emailCtrl, 
                  onChanged: (value){

                      //2.4 Implementando numlook
                      //"Estoy escribiendo, no me tapes los ojos"
                      isChecking?.change(true);

                      //Ajuste de límite de 0 a 100
                      final look = (value.length / 80.0 * 100.0 ).clamp(
                        0.0,
                        100.0);
                        numLook?.value = look;

                        //3.3 Debounce: Si vuelve a teclear, reinicia el contador
                        _typingDebounce?.cancel(); //Cancela cualquier timer existente
                        _typingDebounce = Timer(const Duration(seconds: 3), (){
                          if (! mounted){
                            return; //Si la pantalla se cierra
                          }
                          isChecking?.change (false);
                        });
                    
                    if (isChecking == null) return;
                    //Activa el modo chismoso
                    isChecking!.change(true);
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    //4.9 Mostrar el texto del error 
                    errorText: emailError,
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
                width: size.width,
                child: TextField(
                  //Asignas el focusnode al textfield
                  //4.9 Enlazar controller a TextField
                  controller: passCtrl, 
                  //llamas a la familia chismosa
                  focusNode: passFocus,
                  onChanged: (value){
                    if (isHandsUp != null){ 
                      //No tapar los ojos al escribir

                      //isHandsUp!.change(true);
                    }
                    if (isChecking == null) return;
                    //Activa el modo chismoso
                    isChecking!.change(false);
                  },
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    //4.9 Mosrtrar el texto del error
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
              ),
              SizedBox(height: 10,),
              SizedBox(
                width: 375,
                child: Text('Olvidé mi contraseña', 
                //Alinear a la derecha
                textAlign: TextAlign.end, style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              //Botón de loggin
              //Botón estilo android, todo botón pide una propiedad onPressed, significa que 
              //al usarlo debe hacer algo, o sea no puede quedar vacío, pero podemos ponerle corchetes vacíos
              MaterialButton(
                minWidth: 375,
                height: 50,
                color: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                //4.10 Llamar a la función de login
                onPressed:_onLogin,
                child: Text('Loggin', style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  ),
                ),  
              ),
              SizedBox(height: 10,),
              SizedBox(
                height: 50,
                width: 375,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes una cuenta?'),
                    TextButton(
                      onPressed: (){}, 
                      child: const Text('Registrate', 
                        style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline
                        )
                        ),
                      ),
                    ],
                  ),
              )
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