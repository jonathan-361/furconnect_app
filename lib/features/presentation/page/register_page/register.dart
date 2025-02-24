import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:furconnect/features/data/services/register_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';

class Register extends StatefulWidget {
  Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isCountrySelected = false;
  bool _isStateSelected = false;

  final RegisterService _registerService = RegisterService(ApiService());

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final success = await _registerService.registerUser(
          nameController.text,
          lastNameController.text,
          emailController.text,
          passwordController.text,
          phoneController.text,
          cityController.text,
          stateController.text,
          countryController.text,
        );

        if (success) {
          _showOverlay(context, Colors.green, 'Cuenta creada éxitosamente');
          context.pop();
        }
      } on SocketException catch (_) {
        _showOverlay(context, Colors.red, 'No hay conexión a internet');
      } catch (err) {
        _showOverlay(context, Colors.green, 'Ha ocurrido un error desconocido');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre(s)',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 25,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-ZÀ-ÿ\s]+$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 25,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-ZÀ-ÿ\s]+$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El apellido es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  border: const OutlineInputBorder(),
                  errorText: _emailError,
                  counterText: '',
                ),
                maxLength: 40,
                onChanged: (value) {
                  final regex = RegExp(
                      r"^[a-zA-Z0-9._%+-]+@(gmail\.com|outlook\.com|hotmail\.com)$");
                  if (value.isEmpty) {
                    setState(() {
                      _emailError = 'El correo es obligatorio';
                    });
                  } else if (!regex.hasMatch(value)) {
                    setState(() {
                      _emailError = 'Por favor ingresa un correo válido';
                    });
                  } else {
                    setState(() {
                      _emailError = null; // Si es válido, no hay error
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  final regex = RegExp(
                      r"^[a-zA-Z0-9._%+-]+@(gmail\.com|outlook\.com|hotmail\.com)$");
                  if (!regex.hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null; // Si es válido, no hay error
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  counterText: '',
                  errorText: _passwordError,
                ),
                maxLength: 18,
                onChanged: (value) {
                  setState(
                    () {
                      if (value.length < 8) {
                        _passwordError = 'Debe tener al menos 8 caracteres';
                      } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>._]')
                          .hasMatch(value)) {
                        _passwordError = 'Debe incluir al menos un símbolo';
                      } else if (RegExp(
                              r'(?:012|123|234|345|456|567|678|789|890)')
                          .hasMatch(value)) {
                        _passwordError =
                            'No puede contener números consecutivos';
                      } else if (RegExp(r'^(.)\1*$').hasMatch(value)) {
                        _passwordError =
                            'La contraseña no puede tener caracteres repetidos';
                      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        _passwordError =
                            'Debe incluir al menos una letra mayúscula';
                      } else {
                        _passwordError = null; // Si es válida, no hay error
                      }
                    },
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  return _passwordError;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: const OutlineInputBorder(),
                  counterText: '',
                  errorText: _confirmPasswordError,
                ),
                maxLength: 18,
                onChanged: (value) {
                  setState(() {
                    if (value != passwordController.text) {
                      _confirmPasswordError = 'Las contraseñas no coinciden';
                    } else {
                      _confirmPasswordError = null; // No hay error si coinciden
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Número teléfonico',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El número teléfonico es obligatorio';
                  }
                  if (value.length != 10) {
                    return 'Escribe un número telefónico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'País',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 18,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                ],
                onChanged: (value) {
                  setState(() {
                    _isCountrySelected = value.isNotEmpty;
                    if (!_isCountrySelected) {
                      stateController.clear();
                      cityController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El país es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: stateController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 18,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                ],
                enabled:
                    _isCountrySelected, // Habilitar solo si el país está seleccionado
                onChanged: (value) {
                  setState(() {
                    _isStateSelected = value.isNotEmpty;
                    if (!_isStateSelected) {
                      cityController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (_isCountrySelected && (value == null || value.isEmpty)) {
                    return 'El estado es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 18,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                ],
                enabled:
                    _isStateSelected, // Habilitar solo si el estado está seleccionado
                validator: (value) {
                  if (_isStateSelected && (value == null || value.isEmpty)) {
                    return 'La ciudad es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 228, 121, 59),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 16,
                      ),
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
}
