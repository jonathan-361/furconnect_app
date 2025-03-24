import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';

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

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  Map<String, dynamic> locationData = {};
  List<String> countries = [];
  List<Map<String, dynamic>> states = [];
  List<String> cities = [];

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isLoading = true;

  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  String specialCharacters = "!@#\$%&*(),.?\":{}<>._";

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/countries/countries.json');

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      setState(() {
        locationData = jsonData;
        _initializeCountries();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading countries.json: $e');
      setState(() {
        _isLoading = false;
      });
      // Show an error message using your overlay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppOverlay.showOverlay(
            context, Colors.red, "Error al cargar datos de ubicación");
      });
    }
  }

  void _initializeCountries() {
    if (locationData.containsKey('country')) {
      countries = [locationData['country']['name']];
    } else {
      countries = [];
    }
  }

  void _loadStates(String country) {
    if (locationData.isEmpty || !locationData.containsKey('country')) {
      setState(() {
        states = [];
        selectedState = null;
        selectedCity = null;
        cities = [];
      });
      return;
    }

    if (country == locationData['country']['name']) {
      setState(() {
        states =
            List<Map<String, dynamic>>.from(locationData['country']['states']);
        selectedState = null;
        selectedCity = null;
        cities = [];
      });
    } else {
      setState(() {
        states = [];
        selectedState = null;
        selectedCity = null;
        cities = [];
      });
    }
  }

  void _loadCities(String state) {
    for (var stateData in states) {
      if (stateData['name'] == state) {
        if (mounted) {
          setState(() {
            cities = List<String>.from(stateData['cities']);
            print('Cities for state ${state}: ${cities.length}');
            selectedCity = null;
          });
        }
        return;
      }
    }
    if (mounted) {
      setState(() {
        cities = [];
        selectedCity = null;
      });
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
              const SizedBox(height: 20),
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
                    RegExp(r'^[a-zA-ZÀ-ÿ\s]+$'),
                  ),
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
                    RegExp(r'^[a-zA-ZÀ-ÿ\s]+$'),
                  ),
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
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

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
                      _emailError = null;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  final regex = RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                  if (!regex.hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  suffix: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
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
                        _passwordError =
                            'Incluye símbolos como: $specialCharacters';
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
                        _passwordError = null;
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
                obscureText: _obscureTextConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: const OutlineInputBorder(),
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  suffix: IconButton(
                    icon: Icon(
                      _obscureTextConfirm
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureTextConfirm = !_obscureTextConfirm;
                      });
                    },
                  ),
                  errorText: _confirmPasswordError,
                ),
                maxLength: 18,
                onChanged: (value) {
                  setState(() {
                    if (value != passwordController.text) {
                      _confirmPasswordError = 'Las contraseñas no coinciden';
                    } else {
                      _confirmPasswordError = null;
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'País',
                  border: OutlineInputBorder(),
                ),
                value: selectedCountry,
                hint: const Text('Selecciona un país'),
                isExpanded: true,
                items: countries.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue;
                    if (newValue != null) {
                      _loadStates(newValue);
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                value: selectedState,
                hint: const Text('Selecciona un estado'),
                isExpanded: true,
                items: states.map((Map<String, dynamic> state) {
                  return DropdownMenuItem<String>(
                    value: state['name'],
                    child: Text(state['name']),
                  );
                }).toList(),
                onChanged: selectedCountry == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedState = newValue;
                          if (newValue != null) {
                            _loadCities(newValue);
                          }
                        });
                      },
                validator: (value) {
                  if (selectedCountry != null &&
                      (value == null || value.isEmpty)) {
                    return 'El estado es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Localidad',
                  border: OutlineInputBorder(),
                ),
                value: selectedCity,
                hint: const Text('Selecciona una localidad'),
                isExpanded: true,
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: selectedState == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                validator: (value) {
                  if (selectedState != null &&
                      (value == null || value.isEmpty)) {
                    return 'La localidad es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final userData = {
                          'name': nameController.text,
                          'lastName': lastNameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                          'phone': phoneController.text,
                          'city': selectedCity,
                          'state': selectedState,
                          'country': selectedCountry
                        };
                        context.push('/chooseImage', extra: userData);
                      } else {
                        AppOverlay.showOverlay(context, Colors.red,
                            "Termina de rellenar el formulario");
                      }
                    },
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
                      'Siguiente',
                      textAlign: TextAlign.center,
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
}
