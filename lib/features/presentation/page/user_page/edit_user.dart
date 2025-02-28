import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';
import 'package:furconnect/features/presentation/widget/overlay.dart';
import 'package:furconnect/features/presentation/widget/loading_overlay.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
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

  final _userService = UserService(ApiService(), LoginService(ApiService()));

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String _imageUrl = '';
  String? imagen;
  String specialCharacters = "!@#\$%&*(),.?\":{}<>._";

  String? _error;

  bool _isCountrySelected = false;
  bool _isStateSelected = false;
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  bool _isLoading = false;
  File? _selectedImageFile;

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      final pickedFile = result.files.single;
      final file = File(pickedFile.path!);

      setState(() {
        _selectedImageFile = file;
        _imageUrl = file.path;
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

  Future<String?> uploadImageToCloudinary(File image) async {
    try {
      final compressedImageBytes = await _compressImage(image);
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          compressedImageBytes,
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
        print('URL de la imagen: $imageUrl');
        return imageUrl;
      } else {
        print('Error al subir imagen: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Excepción al subir imagen: $e');
      return null;
    }
  }

  Future<bool> updateUserData() async {
    final loginService = LoginService(ApiService());
    await loginService.loadToken();
    final token = loginService.authToken;
    if (token == null) {
      setState(() {
        _error = 'No se encontró un token válido.';
      });
      return false;
    }

    final decodedToken = JwtDecoder.decode(token);
    final usuarioId = decodedToken['id'];

    if (!_formKey.currentState!.validate()) {
      showLoadingOverlay();
      AppOverlay.showOverlay(context, Colors.red, "Complete todos los datos");
      hideLoadingOverlay();
      return false;
    }

    try {
      showLoadingOverlay();
      if (_selectedImageFile != null) {
        final imageUrl = await uploadImageToCloudinary(_selectedImageFile!);
        if (imageUrl != null) {
          _imageUrl = imageUrl;
        } else {
          AppOverlay.showOverlay(
              context, Colors.red, "Error al subir la imagen");
          hideLoadingOverlay();
          return false;
        }
      }

      final result = await _userService.updateUser(
        usuarioId,
        _imageUrl,
        nameController.text,
        lastNameController.text,
        emailController.text,
        passwordController.text,
        phoneController.text,
        cityController.text,
        stateController.text,
        countryController.text,
      );

      hideLoadingOverlay();

      if (result) {
        AppOverlay.showOverlay(
            context, Colors.green, "Datos actualizados correctamente");
        return true;
      } else {
        AppOverlay.showOverlay(
            context, Colors.red, "Hubo un error al actualizar los datos");
        return false;
      }
    } catch (err) {
      hideLoadingOverlay();
      AppOverlay.showOverlay(context, Colors.red, "Error: $err");
      return false;
    }
  }

  void showLoadingOverlay() {
    setState(() {
      _isLoading = true;
    });
  }

  void hideLoadingOverlay() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = GoRouterState.of(context).extra as Map<String, dynamic>?;

    if (userData != null) {
      nameController.text = userData['nombre'];
      lastNameController.text = userData['apellido'];
      emailController.text = userData['email'];
      phoneController.text = userData['telefono'];
      countryController.text = userData['pais'];
      stateController.text = userData['estado'];
      cityController.text = userData['ciudad'];
      _imageUrl = userData['imagen'];
      _loadStoredPassword();
    }
  }

  Future<void> _loadStoredPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword =
        prefs.getString('password'); // Obtiene la contraseña guardada

    if (storedPassword != null) {
      passwordController.text = storedPassword;
      confirmPasswordController.text = storedPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Editar usuario'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                pickImage(); // Selecciona la imagen
                                print("Editar imagen");
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(0, 0, 0, 0.3),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _selectedImageFile != null
                                      ? FileImage(_selectedImageFile!)
                                          as ImageProvider
                                      : (_imageUrl.isNotEmpty
                                          ? (_imageUrl.startsWith('http')
                                              ? NetworkImage(_imageUrl)
                                              : FileImage(File(_imageUrl))
                                                  as ImageProvider)
                                          : null),
                                  child: _selectedImageFile == null &&
                                          _imageUrl.isEmpty
                                      ? Icon(
                                          Icons.add_a_photo,
                                          size: 50,
                                          color: Colors.grey[600],
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  pickImage();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.4),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.edit,
                                      size: 22,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              _emailError =
                                  'Por favor ingresa un correo válido';
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          suffix: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                                _passwordError =
                                    'Debe tener al menos 8 caracteres';
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
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
                              _confirmPasswordError =
                                  'Las contraseñas no coinciden';
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
                          if (_isCountrySelected &&
                              (value == null || value.isEmpty)) {
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
                          if (_isStateSelected &&
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
                            onPressed: () async {
                              showLoadingOverlay();
                              if (_formKey.currentState!.validate()) {
                                if (confirmPasswordController.text.isEmpty) {
                                  AppOverlay.showOverlay(context, Colors.red,
                                      "Rellena todos los campos");
                                  hideLoadingOverlay();
                                  return;
                                }
                                bool success = await updateUserData();
                                hideLoadingOverlay();
                                if (success) {
                                  AppOverlay.showOverlay(context, Colors.green,
                                      "Datos actualizados correctamente");
                                  context.pop();
                                } else {
                                  AppOverlay.showOverlay(context, Colors.red,
                                      "Hubo un error al actualizar los datos");
                                }
                              } else {
                                AppOverlay.showOverlay(context, Colors.red,
                                    "Rellena todos los campos");
                                hideLoadingOverlay();
                              }
                            },
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
                              'Editar',
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
            ],
          ),
        ),
        if (_isLoading) LoadingOverlay(),
      ],
    );
  }
}
