import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:furconnect/features/data/services/register_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/presentation/widget/overlay.dart';

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
  String? _imageError;

  bool _isCountrySelected = false;
  bool _isStateSelected = false;

  File? _selectedImage;
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  String specialCharacters = "!@#\$%&*(),.?\":{}<>._";

  final RegisterService _registerService = RegisterService(ApiService());

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      setState(() {
        _selectedImage = file;
        _imageError = null;
      });
    }
  }

  Future<Uint8List> _compressImage(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes())!;
    final resizedImage = img.copyResize(image, width: 800);
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 85);

    if (compressedImageBytes.length > 400 * 1024) {
      return _compressImageWithLowerQuality(image);
    }

    return compressedImageBytes;
  }

  Future<Uint8List> _compressImageWithLowerQuality(img.Image image) async {
    final resizedImage = img.copyResize(image, width: 600);
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 70);
    return compressedImageBytes;
  }

  Future<String?> uploadImageDio(File image) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromBytes(
          await image.readAsBytes(),
          filename: 'image.jpg',
        ),
        'upload_preset': 'upload_image_flutter',
      });

      final response = await Dio().post(
        'https://api.cloudinary.com/v1_1/dvt90q1cu/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final imageUrl = response.data['secure_url'];
        print('Imagen subida con éxito: $imageUrl');
        return imageUrl;
      } else {
        print('Error al subir la imagen: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Excepción al subir imagen: $e');
      return null;
    }
  }

  void _register() async {
    setState(() {
      _imageError =
          _selectedImage == null ? 'Debe seleccionar una imagen' : null;
    });

    if (_selectedImage == null) return;

    if (_formKey.currentState?.validate() ?? false) {
      try {
        Uint8List compressedImage = await _compressImage(_selectedImage!);
        File compressedFile = File('${_selectedImage!.path}_compressed.jpg');
        await compressedFile.writeAsBytes(compressedImage);

        String? imageUrl = await uploadImageDio(compressedFile);

        if (imageUrl != null) {
          final success = await _registerService.registerUser(
            imageUrl,
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
            AppOverlay.showOverlay(
                context, Colors.green, "Cuenta creada éxitosamente");
            context.pop();
          }
        } else {
          AppOverlay.showOverlay(
              context, Colors.red, "Error al subir la imagen");
        }
      } on SocketException catch (_) {
        AppOverlay.showOverlay(
            context, Colors.red, "No hay conexión a internet");
      } catch (err) {
        AppOverlay.showOverlay(
            context, Colors.red, "Ha ocurrido un error desconocido");
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
                enabled: _isCountrySelected,
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
                  labelText: 'Localidad',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 18,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$')),
                ],
                enabled: _isStateSelected,
                validator: (value) {
                  if (_isStateSelected && (value == null || value.isEmpty)) {
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
                          'city': cityController.text,
                          'state': stateController.text,
                          'country': countryController.text,
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
