import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final LoginService _loginService;
  String _message = '';
  Color _messageColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _loginService = LoginService(ApiService());
  }

  void _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? token = await _loginService.login(
          _emailController.text,
          _passwordController.text,
        );
        if (token != null) {
          _showOverlay(context, Colors.green, 'Inicio de sesión exitoso');
          await Future.delayed(const Duration(seconds: 2));

          context.go('/navigationBar');
        }
      } catch (e) {
        _showOverlay(context, Colors.red, '$e');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void _showOverlay(BuildContext context, Color color, String message) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.04,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(-5, -130),
              child: Transform.scale(
                scale: 1.05,
                child: Image.asset(
                  'assets/images/Login/pet2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 5,
            height: MediaQuery.of(context).size.height / 7.5,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Image.asset(
                'assets/images/logo_furconnect.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2.8,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Iniciar sesión',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            counterText: '',
                          ),
                          maxLength: 40,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Escribe un correo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            counterText: '',
                          ),
                          maxLength: 18,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Escribe una contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: _validateAndLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 228, 121, 59),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text(
                                    'Iniciar Sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'RobotoR',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  context.push('/register');
                                },
                                child: const Text(
                                  'Crear una cuenta',
                                  style: TextStyle(
                                    fontFamily: 'RobotoR',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
