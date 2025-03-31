import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'package:furconnect/features/data/services/register_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class ChooseImage extends StatefulWidget {
  final Map<String, String?> userData;
  final RegisterService registerService;

  const ChooseImage({
    super.key,
    required this.userData,
    required this.registerService,
  });

  @override
  _ChooseImageState createState() => _ChooseImageState();
}

class _ChooseImageState extends State<ChooseImage> {
  File? _selectedImage;
  bool _isLoading = false;

  Future<File?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (err) {
      print('Error al seleccionar imagen: $err');
      AppOverlay.showOverlay(
          context, Colors.red, "Error al seleccionar imagen");
      return null;
    }
  }

  Future<Uint8List> compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('No se pudo decodificar la imagen');

      final resizedImage = img.copyResize(image, width: 800);
      return img.encodeJpg(resizedImage, quality: 85);
    } catch (e) {
      print('Error al comprimir imagen: $e');
      return await imageFile.readAsBytes();
    }
  }

  Future<String?> _uploadImageWithRetry(File image, {int retries = 2}) async {
    for (int i = 0; i < retries; i++) {
      try {
        // Comprimir imagen
        final compressedBytes = await compressImage(image);
        final tempDir = await getTemporaryDirectory();
        final compressedFile = File(
            '${tempDir.path}/compressed_profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await compressedFile.writeAsBytes(compressedBytes);

        // Verificar que el archivo existe
        if (!await compressedFile.exists()) {
          throw Exception('El archivo comprimido no se creó correctamente');
        }

        // Subir a Cloudinary
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(compressedFile.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'),
          'upload_preset': 'image_user_preset',
          'folder': 'users',
        });

        final response = await Dio().post(
          'https://api.cloudinary.com/v1_1/dvt90q1cu/upload',
          data: formData,
          options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        if (response.statusCode == 200) {
          return response.data['secure_url'] as String;
        }
      } on DioException catch (e) {
        print('Intento ${i + 1} fallido: ${e.message}');
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('Intento ${i + 1} fallido: $e');
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return null;
  }

  Future<void> registerUser(File? imageFile, BuildContext context) async {
    String? imageUrl;
    showLoadingOverlay();

    try {
      // Paso 1: Manejo de la imagen (solo si se proporciona)
      if (imageFile != null) {
        try {
          imageUrl = await _uploadImageWithRetry(imageFile);
          if (imageUrl == null) {
            AppOverlay.showOverlay(context, Colors.orange,
                "No se pudo subir la imagen. Continuando sin foto de perfil");
          }
        } catch (e) {
          print('Error crítico al subir imagen: $e');
          AppOverlay.showOverlay(context, Colors.orange,
              "Error al procesar imagen, continuando sin ella");
        }
      }

      // Paso 2: Validar datos requeridos
      final requiredFields = ['name', 'lastName', 'email', 'password', 'phone'];
      for (final field in requiredFields) {
        if (widget.userData[field] == null || widget.userData[field]!.isEmpty) {
          throw Exception('El campo $field es requerido');
        }
      }

      // Paso 3: Registrar usuario (con o sin imagen)
      final success = await widget.registerService.registerUser(
        imageUrl ?? '', // Cadena vacía si no hay imagen
        widget.userData['name']!,
        widget.userData['lastName']!,
        widget.userData['email']!,
        widget.userData['password']!,
        widget.userData['phone']!,
        widget.userData['city'] ?? '',
        widget.userData['state'] ?? '',
        widget.userData['country'] ?? '',
      );

      if (!success) {
        throw Exception('El servicio de registro devolvió false');
      }

      // Paso 4: Guardar credenciales y hacer login automático
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', widget.userData['email']!);
      await prefs.setString('password', widget.userData['password']!);

      final loginService = LoginService(ApiService());
      final loginSuccess = await loginService.login(
          widget.userData['email']!, widget.userData['password']!);

      // Paso 5: Navegar a la siguiente pantalla
      if (mounted) {
        context.go('/newPetUser');
      }
    } catch (e) {
      print('Error durante el registro: $e');
      if (mounted) {
        AppOverlay.showOverlay(
            context, Colors.red, "Error al crear la cuenta: ${e.toString()}");
      }
    } finally {
      hideLoadingOverlay();
    }
  }

  void showImageConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("¿Continuar sin imagen?"),
          content: const Text(
              "Puedes agregar una foto de perfil más tarde desde la configuración de tu cuenta."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                registerUser(null, context);
              },
              child: const Text("Continuar"),
            ),
          ],
        );
      },
    );
  }

  void showLoadingOverlay() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  void hideLoadingOverlay() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Foto de perfil'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Agrega una foto de perfil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '(Opcional)',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Área de selección de imagen
                GestureDetector(
                  onTap: () async {
                    final image = await pickImage();
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // Botón de continuar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedImage != null) {
                        registerUser(_selectedImage, context);
                      } else {
                        showImageConfirmationDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4793B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }
}
