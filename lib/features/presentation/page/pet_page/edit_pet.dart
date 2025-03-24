import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:io';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';

class EditPet extends StatelessWidget {
  EditPet({super.key});
  final PetService _petService =
      PetService(ApiService(), LoginService(ApiService()));

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _typeController = TextEditingController();
  final _colorController = TextEditingController();
  final _ageController = TextEditingController();
  final _temperamentController = TextEditingController();
  final _vacuumController = TextEditingController();

  final List<String> sizes = ['Pequeño', 'Mediano', 'Grande'];
  final List<String> genders = ['Macho', 'Hembra'];
  String? _error;

  @override
  Widget build(BuildContext context) {
    final petData = GoRouterState.of(context).extra as Map<String, dynamic>;
    _nameController.text = petData['nombre'];
    _breedController.text = petData['raza'];
    _typeController.text = petData['tipo'];
    _colorController.text = petData['color'];
    _ageController.text = petData['edad'].toString();
    _temperamentController.text = petData['temperamento'] ?? '';

    bool _hasPedigree = petData['pedigree'] ?? false;
    String? selectedSize = petData['tamaño'] != null
        ? petData['tamaño']!.substring(0, 1).toUpperCase() +
            petData['tamaño']!.substring(1).toLowerCase()
        : null;
    String? selectedGender = petData['sexo'] != null
        ? petData['sexo']!.substring(0, 1).toUpperCase() +
            petData['sexo']!.substring(1).toLowerCase()
        : null;

    List<String> vaccines = List<String>.from(petData['vacunas'] ?? []);
    List<String> imagesPet = List<String>.from(petData['media']);

    Future<bool> _updatePet() async {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;
      if (token == null) {
        _error = 'No se encontró un token válido.';
        return false;
      }

      final decodedToken = JwtDecoder.decode(token);
      final usuarioId = decodedToken['id'];

      try {
        final success = await _petService.updatePet(
          petData['_id'],
          _nameController.text,
          _breedController.text,
          _typeController.text,
          _colorController.text,
          selectedSize ?? 'Tamaño desconocido',
          int.tryParse(_ageController.text) ?? 0,
          selectedGender ?? 'No definido aún',
          _hasPedigree,
          vaccines,
          _temperamentController.text,
          usuarioId,
          imagesPet,
        );

        if (success) {
          _error = 'Mascota registrada con éxito.';
          Future.delayed(const Duration(milliseconds: 300), () {
            context.pop();
          });
          return true;
        } else {
          _error = 'Error al registrar la mascota.';
          return false;
        }
      } on SocketException catch (_) {
        _error = 'Error de conexión. Verifica tu conexión a internet.';
        print(_error);
        return false;
      } catch (e) {
        _error = 'Error al registrar la mascota: $e';

        print(_error);
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar mascota'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      if (imagesPet.isNotEmpty)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imagesPet.first,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 200,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                      child:
                                          Icon(Icons.broken_image, size: 50)),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre",
                          counterText: '',
                          filled: true,
                        ),
                        maxLength: 18,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa un nombre";
                          }
                          return null;
                        },
                        enabled: false,
                      ),
                      TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: "Raza",
                          counterText: '',
                          filled: true,
                        ),
                        maxLength: 18,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa una raza";
                          }
                          return null;
                        },
                        enabled: false,
                      ),
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: "Tipo",
                          counterText: '',
                        ),
                        maxLength: 18,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa un tipo";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: "Color",
                          counterText: '',
                        ),
                        maxLength: 25,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s,\/]+$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa un color";
                          }
                          return null;
                        },
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButtonFormField<String>(
                            value: selectedSize,
                            decoration:
                                const InputDecoration(labelText: 'Tamaño'),
                            items: sizes.map((String size) {
                              return DropdownMenuItem<String>(
                                value: size,
                                child: Text(size),
                              );
                            }).toList(),
                            onChanged: (String? newSize) {
                              setState(() {
                                selectedSize = newSize;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor selecciona un tamaño";
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: "Edad",
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa una edad";
                          }
                          return null;
                        },
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Sexo',
                              filled: true,
                            ),
                            items: genders.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor selecciona el sexo";
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      TextFormField(
                        controller: _temperamentController,
                        decoration: const InputDecoration(
                          labelText: "Temperamento",
                          counterText: '',
                        ),
                        maxLength: 15,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa un temperamento";
                          }
                          return null;
                        },
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              TextFormField(
                                controller: _vacuumController,
                                decoration: const InputDecoration(
                                  labelText: "Vacunas",
                                  counterText: '',
                                ),
                                maxLength: 15,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                                ],
                                onChanged: (value) {
                                  // Asegúrate de que el valor no esté vacío antes de agregarlo
                                  if (value.trim().isNotEmpty &&
                                      value.contains(' ')) {
                                    setState(() {
                                      vaccines.add(value.trim());
                                      _vacuumController.clear();
                                    });
                                  }
                                },
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: vaccines.map((vaccine) {
                                  return Chip(
                                    label: Text(vaccine),
                                    deleteIcon: const Icon(Icons.close),
                                    onDeleted: () {
                                      setState(() {
                                        vaccines.remove(vaccine);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Row(
                            children: [
                              const Text("Pedigree:"),
                              Checkbox(
                                value: _hasPedigree,
                                onChanged: null,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _updatePet();
                                  print('Cambios guardados');
                                }
                              },
                              child: const Text(
                                "Aceptar cambios",
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
