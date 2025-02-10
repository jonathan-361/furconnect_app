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
  String _message = ''; // Variable para el mensaje
  Color _messageColor = Colors.transparent; // Color inicial

  @override
  void initState() {
    super.initState();
    // Inicializamos el servicio de Login
    _loginService = LoginService(ApiService());
  }

  void _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Intentamos realizar el login
        String? token = await _loginService.login(
          _emailController.text,
          _passwordController.text,
        );
        if (token != null) {
          setState(() {
            _message = 'Inicio de sesión exitoso';
            _messageColor = Colors.green;
          });

          // Esperamos 2 segundos antes de navegar
          await Future.delayed(const Duration(seconds: 2));

          // Si el login es exitoso, navegamos al 'navigationBar'
          context.go('/navigationBar');
        }
      } catch (e) {
        setState(() {
          _message = 'Error: $e';
          _messageColor = Colors.red;
        });

        // Esperamos 2 segundos antes de desaparecer el mensaje
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _message = ''; // Ocultamos el mensaje después de 2 segundos
          _messageColor = Colors.transparent;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Column(
        children: [
          // Mensaje superior que aparece y desaparece
          AnimatedOpacity(
            opacity: _messageColor == Colors.transparent ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: _messageColor,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _message,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Formulario de login
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                          ElevatedButton(
                            onPressed: _validateAndLogin,
                            child: const Text('Iniciar Sesión'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              context.push('/register');
                            },
                            child: const Text('Crear una cuenta'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
