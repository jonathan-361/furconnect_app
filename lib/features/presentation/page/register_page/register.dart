import 'package:flutter/material.dart';

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
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isCountrySelected = false;
  bool _isStateSelected = false;

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
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'País',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 18,
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
                child: ElevatedButton(
                  onPressed: () {
                    // Validar el formulario
                    if (_formKey.currentState!.validate()) {
                      // Si es válido, hacer lo que necesites (guardar, navegar, etc.)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Formulario válido')),
                      );
                    } else {
                      // Si no es válido, Flutter ya muestra los errores
                    }
                  },
                  child: const Text('Crear cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
