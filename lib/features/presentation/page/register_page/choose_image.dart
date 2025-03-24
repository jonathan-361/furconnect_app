import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:furconnect/features/data/services/register_service.dart';
import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class ChooseImage extends StatefulWidget {
  final Map<String, String> userData;
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
  final String defaultImageUrl =
      "https://static.vecteezy.com/system/resources/previews/021/548/095/original/default-profile-picture-avatar-user-avatar-icon-person-icon-head-icon-profile-picture-icons-default-anonymous-user-male-and-female-businessman-photo-placeholder-social-network-avatar-portrait-free-vector.jpg";

  Future<File?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<Uint8List> compressImage(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes())!;
    final resizedImage = img.copyResize(image, width: 800);
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 85);

    if (compressedImageBytes.length > 400 * 1024) {
      return compressImageWithLowerQuality(image);
    }

    return compressedImageBytes;
  }

  Future<Uint8List> compressImageWithLowerQuality(img.Image image) async {
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

  Future<void> register(File? selectedImage, BuildContext context) async {
    String imageUrl = defaultImageUrl;
    showLoadingOverlay();

    if (selectedImage != null) {
      try {
        Uint8List compressedImage = await compressImage(selectedImage);
        File compressedFile = File('${selectedImage.path}_compressed.jpg');
        await compressedFile.writeAsBytes(compressedImage);

        String? uploadedImageUrl = await uploadImageDio(compressedFile);
        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        } else {
          AppOverlay.showOverlay(
              context, Colors.red, "Error al subir la imagen");
          hideLoadingOverlay();
          return;
        }
      } on SocketException {
        AppOverlay.showOverlay(
            context, Colors.red, "No hay conexión a internet");
        hideLoadingOverlay();
        return;
      } catch (err) {
        AppOverlay.showOverlay(
            context, Colors.red, "Ha ocurrido un error desconocido");
        hideLoadingOverlay();
        return;
      }
    }

    final success = await widget.registerService.registerUser(
      imageUrl,
      widget.userData['name']!,
      widget.userData['lastName']!,
      widget.userData['email']!,
      widget.userData['password']!,
      widget.userData['phone']!,
      widget.userData['city']!,
      widget.userData['state']!,
      widget.userData['country']!,
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', widget.userData['email']!);
      await prefs.setString('password', widget.userData['password']!);

      try {
        final loginService = LoginService(ApiService());
        await loginService.login(
            widget.userData['email']!, widget.userData['password']!);
        print('Cuenta creada exitosamente');
        context.go('/newPetUser');
      } catch (err) {
        AppOverlay.showOverlay(context, Colors.red,
            "Error al iniciar sesión automáticamente: $err");
      }
    } else {
      AppOverlay.showOverlay(context, Colors.red, "Error al crear la cuenta");
    }
    hideLoadingOverlay();
  }

  void showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar"),
          content: Text("¿Deseas crear tu cuenta sin una foto de perfil?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                register(null, context);
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Escoge tu imagen de perfil'),
          ),
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Escoge una imagen de perfil',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            '(Opcional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30),
                          GestureDetector(
                            onTap: () async {
                              final pickedImage = await pickImage();
                              if (pickedImage != null) {
                                setState(() {
                                  _selectedImage = pickedImage;
                                });
                              }
                            },
                            child: CircleAvatar(
                              radius: 120,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : null,
                              child: _selectedImage == null
                                  ? Icon(
                                      Icons.add_a_photo,
                                      size: 50,
                                      color: Colors.grey[600],
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_selectedImage != null) {
                                  register(_selectedImage, context);
                                } else {
                                  showConfirmDialog(context);
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
                                'Terminar de crear cuenta',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLoading) LoadingOverlay(),
      ],
    );
  }
}
