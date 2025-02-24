import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
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
  final PageController _pageController = PageController();

  bool _hasPedigree = false;
  String? selectedSize;
  String? selectedGender;
  List<String> vaccines = [];
  List<File> _selectedImages = [];
  bool _imageError = false;
  String? _error;
  List<String> imagesPet = [];

  final List<String> sizes = ['Pequeño', 'Mediano', 'Grande'];
  final List<String> genders = ['Macho', 'Hembra'];

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      List<File> compressedImages = [];
      for (var file in result.files) {
        Uint8List compressedImageBytes = await _compressImage(File(file.path!));
        // Guardar los bytes comprimidos en un archivo temporal
        final tempFile = File(
            '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(compressedImageBytes);
        compressedImages.add(tempFile);
      }

      setState(() {
        _selectedImages = compressedImages.take(4).toList();
        _imageError = false;
      });
      print('Imágenes seleccionadas y comprimidas: ${_selectedImages.length}');
    }
  }

  Future<Uint8List> _compressImage(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes())!;
    final resizedImage =
        img.copyResize(image, width: 800); // Redimensionar la imagen
    final compressedImageBytes =
        img.encodeJpg(resizedImage, quality: 85); // Comprimir la imagen

    if (compressedImageBytes.length > 400 * 1024) {
      return _compressImageWithLowerQuality(
          image); // Comprimir más si es necesario
    }

    return compressedImageBytes;
  }

  Future<Uint8List> _compressImageWithLowerQuality(img.Image image) async {
    final resizedImage = img.copyResize(image, width: 600); // Redimensionar más
    final compressedImageBytes =
        img.encodeJpg(resizedImage, quality: 70); // Comprimir más
    return compressedImageBytes;
  }

  Future<List<String>> uploadImagesDio(List<File> images) async {
    List<String> uploadedUrls = [];

    for (File image in images) {
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
          uploadedUrls.add(imageUrl);
          print('URL de la imagen: $imageUrl');
        } else {
          print('Error al subir imagen: ${response.statusMessage}');
        }
      } catch (e) {
        print('Excepción al subir imagen: $e');
      }
    }
    return uploadedUrls;
  }

  Future<bool> _addPet() async {
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

    if (_formKey.currentState?.validate() ?? false) {
      int agePet = int.parse(_ageController.text);

      try {
        if (_selectedImages.isNotEmpty) {
          List<String> uploadedUrls = await uploadImagesDio(_selectedImages);

          if (uploadedUrls.isNotEmpty) {
            imagesPet = uploadedUrls;
          } else {
            setState(() {
              _error = 'Error al subir imágenes.';
            });
            _showOverlay(context, Colors.red, 'Error al subir imágenes');
            return false;
          }
        }

        String mainImage = imagesPet.isNotEmpty ? imagesPet.first : "";
        List<String> mediaImages =
            imagesPet.length > 1 ? imagesPet.sublist(1) : [];

        final success = await _petService.addPet(
          mainImage,
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
          mediaImages,
        );

        if (success) {
          _showOverlay(context, Colors.green, 'Mascota registrada con éxito.');
          print(_error);

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              context.pop();
            }
          });
          return true;
        } else {
          setState(() {
            _error = 'Error al registrar la mascota.';
          });
          _showOverlay(context, Colors.red, 'Error al registrar la mascota.');
          return false;
        }
      } on SocketException catch (_) {
        setState(() {
          _error = 'Error de conexión. Verifica tu conexión a internet.';
        });
        _showOverlay(context, Colors.red,
            'Error de conexión. Verifica tu conexión a internet');
        print(_error);
        return false;
      } catch (e) {
        setState(() {
          _error = 'Error al registrar la mascota: $e';
        });
        _showOverlay(context, Colors.red, 'Error al registrar la mascota: $e');
        print(_error);
        return false;
      }
    }

    return false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar mascota"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 20,
          fontFamily: 'RobotoR',
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            context.pop();
          },
        ),
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
                        onTap: _pickFiles,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: _selectedImages.isNotEmpty ? 250 : 200,
                              constraints: _selectedImages.isNotEmpty
                                  ? const BoxConstraints(maxHeight: 400)
                                  : null,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _selectedImages.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          PageView.builder(
                                            controller: _pageController,
                                            itemCount: _selectedImages.length,
                                            itemBuilder: (context, index) {
                                              return Image.file(
                                                _selectedImages[index],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              );
                                            },
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: SmoothPageIndicator(
                                                controller: _pageController,
                                                count: _selectedImages.length,
                                                effect: WormEffect(
                                                  dotHeight: 8,
                                                  dotWidth: 8,
                                                  activeDotColor: Colors.blue,
                                                  dotColor: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            if (_imageError)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "Por favor selecciona una imagen",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
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
                      ),
                      TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: "Raza",
                          counterText: '',
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
                          child: const Text(
                            "Agregar mascota",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
