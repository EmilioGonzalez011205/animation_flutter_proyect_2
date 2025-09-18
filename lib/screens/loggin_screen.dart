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
  

  //Cerebro de la lógica de las animaciones.
  StateMachineController? controller;
  // SMI = State Machine Input
  SMIBool? isChecking; //Activa el modo chismoso
  SMIBool? isHandsUp; //Se tapa los ojos
  SMITrigger? trigSuccess; //Se emociona
  SMITrigger? trigFail; //Se pone sad 

  @override
  Widget build(BuildContext context) {
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
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Campo Email
              SizedBox(
                width: 375,
                child: TextField(
                  onChanged: (value){
                    if (isHandsUp != null){ 
                      //No tapar los ojos al escribir

                      isHandsUp!.change(false);
                    }
                    if (isChecking == null) return;
                    //Activa el modo chismoso
                    isChecking!.change(true);
                  },
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
                onPressed: () {
                  //TODO: Acción al presionar el botón
                },
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