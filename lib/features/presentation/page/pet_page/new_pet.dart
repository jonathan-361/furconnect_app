import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';

class NewPet extends StatefulWidget {
  const NewPet({super.key});

  @override
  _NewPetState createState() => _NewPetState();
}

class _NewPetState extends State<NewPet> {
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

  bool _hasPedigree = false;
  String? selectedSize;
  String? selectedGender;
  List<String> vaccines = [];
  File? _selectedImage;
  bool _imageError = false;
  String? _error;
  List<String> imagesPet = [];

  final List<String> sizes = ['Pequeño', 'Mediano', 'Grande'];
  final List<String> genders = ['Macho', 'Hembra'];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
        _imageError = false;
      });
      print('Imagen seleccionada: ${_selectedImage!.path}');
    }
  }

  Future<String?> uploadImageDio(File imageFile) async {
    try {
      final url = 'https://api.cloudinary.com/v1_1/dvt90q1cu/upload';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': 'upload_image_flutter'
      });

      final response = await Dio().post(url, data: formData);
      if (response.statusCode == 200) {
        final imageUrl = response.data['secure_url'];
        print('URL de la imagen: $imageUrl');
        return imageUrl; // Retorna la URL para usarla en otro lugar
      } else {
        print('Error al subir la imagen: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Excepción al subir imagen: $e');
      return null;
    }
  }

  Future<bool> _addPet() async {
    final loginService = LoginService(ApiService());
    await loginService.loadToken();
    final token = loginService.authToken;
    if (token == null) {
      setState(() {
        _error = 'No se encontro un token válido.';
      });
      return false;
    }
    final decodedToken = JwtDecoder.decode(token);
    final usuarioId = decodedToken['id'];

    if (_formKey.currentState?.validate() ?? false) {
      int agePet = int.parse(_ageController.text);

      try {
        imagesPet.clear();

        if (_selectedImage != null) {
          String? imageUrl = await uploadImageDio(_selectedImage!);
          if (imageUrl != null) {
            imagesPet.add(imageUrl);
          }
        }

        final success = await _petService.addPet(
          _nameController.text,
          _breedController.text,
          _typeController.text,
          _colorController.text,
          selectedSize ?? 'Tamaño desconocido',
          agePet,
          selectedGender ?? 'No definido aún',
          _hasPedigree,
          vaccines,
          _temperamentController.text,
          usuarioId,
          imagesPet,
        );
        if (success) {
          setState(() {
            _error = 'Mascota registrada con éxito.';
          });
          _showSnackBar('Mascota registrada con éxito.', Colors.green);
          print(_error);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              context.pop();
            }
          });
          return true;
        }
      } on SocketException catch (_) {
        setState(() {
          _error = 'Error de conexión. Verifica tu conexión a internet.';
        });
        _showSnackBar(
            'Error de conexión. Verifica tu conexión a internet.', Colors.red);
        print(_error);
        return false;
      } catch (e) {
        setState(() {
          _error = 'Error al registrar la mascota: $e';
        });
        _showSnackBar('Error al registrar la mascota: $e', Colors.red);
        print(_error);
        return false;
      }
    }
    return false;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar mascota"),
        centerTitle: true,
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
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          width: double.infinity,
                          height: _selectedImage != null ? null : 200,
                          constraints: _selectedImage != null
                              ? const BoxConstraints(maxHeight: 400)
                              : null,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (_imageError) // Muestra el error si no se ha seleccionado imagen
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Por favor selecciona una imagen",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre",
                          counterText: '',
                        ),
                        maxLength: 18,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa un nombre";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: "Raza",
                          counterText: '',
                        ),
                        maxLength: 18,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa una raza";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(
                          labelText: "Tipo",
                          counterText: '',
                        ),
                        maxLength: 18,
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
                        maxLength: 15,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa un color";
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedSize,
                        decoration: const InputDecoration(labelText: 'Tamaño'),
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
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(labelText: 'Sexo'),
                        items: genders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (String? newGender) {
                          setState(() {
                            selectedGender = newGender;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor selecciona el sexo";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _temperamentController,
                        decoration: const InputDecoration(
                          labelText: "Temperamento",
                          counterText: '',
                        ),
                        maxLength: 15,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingresa un temperamento";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _vacuumController,
                        decoration: const InputDecoration(
                          labelText: "Vacunas",
                          counterText: '',
                        ),
                        maxLength: 15,
                        onChanged: (value) {
                          // Asegúrate de que el valor no esté vacío antes de agregarlo
                          if (value.trim().isNotEmpty && value.contains(' ')) {
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
                      Row(
                        children: [
                          const Text("Pedigree:"),
                          Checkbox(
                            value: _hasPedigree,
                            onChanged: (bool? value) {
                              setState(
                                () {
                                  _hasPedigree = value ?? false;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _addPet,
                          child: const Text("Agregar mascota"),
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
