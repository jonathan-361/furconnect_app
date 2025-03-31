import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/data/services/cloudinary_service.dart';
import 'package:furconnect/features/presentation/page/pet_page/listOptions/temperamentList.dart';
import 'package:furconnect/features/presentation/page/pet_page/listOptions/breedList.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class EditPet extends StatefulWidget {
  const EditPet({super.key});

  @override
  _EditPetState createState() => _EditPetState();
}

class MaxAgeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newText.isNotEmpty && int.tryParse(newText) != null) {
      final int value = int.parse(newText);
      if (value > 15) {
        return oldValue;
      }
    }
    return newValue;
  }
}

class _EditPetState extends State<EditPet> {
  final PetService _petService =
      PetService(ApiService(), LoginService(ApiService()));
  final UserService _userService =
      UserService(ApiService(), LoginService(ApiService()));
  final CloudinaryService _cloudinaryService =
      CloudinaryService(ApiService(), LoginService(ApiService()));

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _ageController = TextEditingController();
  final _vacuumController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.3);

  bool _hasPedigree = false;
  String? selectedSize;
  String? selectedGender;
  String? selectedTemperament;
  List<String> vaccines = [];
  List<File?> _selectedImages = [null, null, null, null];
  bool _imageError = false;
  String? _error;
  List<String> imagesPet = [];
  String? _petId;
  bool _initialDataLoaded = false;

  final List<String> sizes = ['Pequeño', 'Mediano', 'Grande'];
  final List<String> genders = ['Macho', 'Hembra'];
  List<String> _existingImageUrls = [];

  String petPlus = 'assets/images/svg/pet.svg';
  bool _isLoading = false;

  // In _EditPetState class
  @override
  void didUpdateWidget(EditPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        'Widget updated - Size: $selectedSize, Temperament: $selectedTemperament');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Editar mascota"),
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
                          SizedBox(
                            height: 120,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(4, (index) {
                                  Widget imageWidget;
                                  if (index < _selectedImages.length &&
                                      _selectedImages[index] != null) {
                                    imageWidget = ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _selectedImages[index]!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    );
                                  } else if (index <
                                      _existingImageUrls.length) {
                                    imageWidget = ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        _existingImageUrls[index],
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(Icons.error),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    // Mostrar el ícono para agregar nueva imagen
                                    imageWidget = Center(
                                      child: SvgPicture.asset(
                                        petPlus,
                                        height: 50,
                                        width: 50,
                                        colorFilter: ColorFilter.mode(
                                          const Color.fromARGB(
                                              255, 153, 91, 62),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () => _pickFiles(index),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: imageWidget,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          if (_imageError)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "Selecciona una imagen",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 10),
                              ),
                            ),
                          const SizedBox(height: 10),
                          FixedHeightFormField(
                            controller: _nameController,
                            labelText: "Nombre",
                            maxLength: 18,
                            enabled: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-ñÑZáéíóúÁÉÍÓÚ\s]+$')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor ingresa un nombre";
                              }
                              return null;
                            },
                          ),
                          Container(
                            height: 70,
                            child: Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return breedList.where((breed) => breed
                                    .toLowerCase()
                                    .contains(
                                        textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (String selection) {
                                _breedController.text = selection;
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onEditingComplete) {
                                // Reemplazamos el controlador temporal por nuestro controlador persistente
                                controller.text = _breedController.text;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    String? errorText;
                                    return TextFormField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      onEditingComplete: onEditingComplete,
                                      enabled: false,
                                      decoration: InputDecoration(
                                        labelText: "Raza",
                                        counterText: '',
                                        errorText: errorText,
                                      ),
                                      style: const TextStyle(fontSize: 17),
                                      maxLength: 18,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^[a-zA-ñÑZáéíóúÁÉÍÓÚ\s]+$'),
                                        ),
                                      ],
                                      validator: (value) {
                                        _breedController.text = controller.text;
                                        if (value == null || value.isEmpty) {
                                          setState(() {
                                            errorText =
                                                "Por favor ingresa una raza";
                                          });
                                          return "Por favor ingresa una raza";
                                        }
                                        if (!breedList.any((breed) =>
                                            breed.toLowerCase() ==
                                            value.trim().toLowerCase())) {
                                          setState(() {
                                            errorText =
                                                "Selecciona una raza válida de la lista";
                                          });
                                          return "Selecciona una raza válida de la lista";
                                        }
                                        setState(() {
                                          errorText = null;
                                        });
                                        return null;
                                      },
                                      onChanged: (text) {
                                        _breedController.text = text;
                                        if (errorText != null) {
                                          setState(() {
                                            errorText = null;
                                          });
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          FixedHeightFormField(
                            controller: _colorController,
                            labelText: "Color",
                            maxLength: 25,
                            style: TextStyle(fontSize: 17),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-ñÑZáéíóúÁÉÍÓÚ\s,\/]+$')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor ingresa un color";
                              }
                              return null;
                            },
                          ),
                          FixedHeightDropdownField<String>(
                            value: selectedSize,
                            labelText: 'Tamaño',
                            items: sizes.map((String size) {
                              return DropdownMenuItem<String>(
                                value: size,
                                child: Text(size),
                              );
                            }).toList(),
                            onChanged: (String? newSize) {
                              if (newSize != null && newSize != selectedSize) {
                                // Add this check
                                setState(() {
                                  selectedSize = newSize;
                                  print('Size updated to: $selectedSize');
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor selecciona un tamaño";
                              }
                              return null;
                            },
                          ),
                          FixedHeightFormField(
                            controller: _ageController,
                            labelText: "Edad",
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 17),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                              MaxAgeInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor ingresa una edad";
                              }
                              final age = int.tryParse(value);
                              if (age == null || age <= 0) {
                                return "Edad inválida";
                              }
                              if (age > 15) {
                                return "La edad no puede ser mayor de 15";
                              }
                              return null;
                            },
                          ),
                          FixedHeightDropdownField<String>(
                            value: selectedGender,
                            labelText: 'Sexo',
                            enabled: false,
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
                          FixedHeightDropdownField<String>(
                            value: selectedTemperament,
                            labelText: 'Temperamento',
                            items: temperaments.map((String temperament) {
                              return DropdownMenuItem<String>(
                                value: temperament,
                                child: Text(temperament),
                              );
                            }).toList(),
                            onChanged: (String? newTemperament) {
                              setState(() {
                                selectedTemperament = newTemperament;
                                print(
                                    'Temperament updated to: $selectedTemperament'); // Debug log
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor selecciona el temperamento";
                              }
                              return null;
                            },
                          ),
                          FixedHeightFormField(
                            controller: _vacuumController,
                            labelText: "Vacunas",
                            maxLength: 15,
                            style: TextStyle(fontSize: 17),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-ñÑZáéíóúÁÉÍÓÚ\s]+$')),
                            ],
                            onChanged: (value) {
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
                          Row(
                            children: [
                              const Text("Pedigree:"),
                              Checkbox(
                                value: _hasPedigree,
                                onChanged: null, // Esto deshabilita el checkbox
                                fillColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors
                                        .grey; // Color cuando está deshabilitado
                                  }
                                  return Color.fromARGB(
                                      255, 228, 121, 59); // Color normal
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: _updatePet,
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
                                "Actualizar mascota",
                                style: TextStyle(
                                  fontSize: 18,
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
        ),
        if (_isLoading) LoadingOverlay(),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final petData = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (_initialDataLoaded) return;

    if (petData != null) {
      final sizePet = petData['tamaño']?.toString();
      final genderPet = petData['sexo']?.toString();
      final temperamentPet = petData['temperamento']?.toString();

      _nameController.text = petData['nombre'] ?? '';
      _breedController.text = petData['raza'] ?? '';
      _colorController.text = petData['color'] ?? '';
      _ageController.text = petData['edad']?.toString() ?? '';
      if (petData['vacunas'] != null) {
        if (petData['vacunas'] is List) {
          vaccines = List<String>.from(petData['vacunas'])
              .expand((v) => v.toString().split(' '))
              .where((v) => v.isNotEmpty)
              .toList();
        } else if (petData['vacunas'] is String) {
          vaccines =
              petData['vacunas'].split(' ').where((v) => v.isNotEmpty).toList();
        }
      } else {
        vaccines = [];
      }

      setState(() {
        selectedSize = sizes.firstWhere(
          (size) => size.toLowerCase() == sizePet?.toLowerCase(),
          orElse: () => sizePet ?? '',
        );

        selectedGender = genders.firstWhere(
          (gender) => gender.toLowerCase() == genderPet?.toLowerCase(),
          orElse: () => genderPet ?? '',
        );

        selectedTemperament = temperaments.firstWhere(
          (temperament) =>
              temperament.toLowerCase().trim() ==
              temperamentPet?.toLowerCase().trim(),
          orElse: () => temperaments.isNotEmpty ? temperaments[0] : '',
        );

        _hasPedigree = petData['pedigree'] == true ||
            petData['pedigree']?.toString().toLowerCase() == 'true';
      });

      _existingImageUrls.clear();

      if (petData['imagen'] != null &&
          petData['imagen'].toString().isNotEmpty) {
        _existingImageUrls.add(petData['imagen'].toString());
      }

      if (petData['media'] is List) {
        _existingImageUrls.addAll((petData['media'] as List)
            .whereType<String>()
            .where((url) => url.isNotEmpty));
      }
    }

    if (petData != null) {
      _petId = petData['_id']?.toString();
      _initialDataLoaded = true;
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

  Future<void> _pickFiles(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      List<File> compressedImages = [];
      for (var file in result.files) {
        Uint8List compressedImageBytes = await _compressImage(File(file.path!));
        final tempFile = File(
            '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(compressedImageBytes);
        compressedImages.add(tempFile);
      }

      setState(() {
        for (int i = 0; i < compressedImages.length && index + i < 4; i++) {
          _selectedImages[index + i] = compressedImages[i];
        }
        _imageError = false;
      });
      print('Imágenes seleccionadas y comprimidas: ${_selectedImages.length}');
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

  Future<List<String>> uploadImagesDio(List<File> images) async {
    List<String> uploadedUrls = [];

    for (File image in images) {
      try {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromBytes(
            await image.readAsBytes(),
            filename: 'image.jpg',
          ),
          'upload_preset': 'image_pet_preset',
          'folder': 'pets',
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

  Future<String?> _getUserId() async {
    try {
      final loginService = LoginService(ApiService());
      await loginService.loadToken();
      final token = loginService.authToken;

      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'];
    } catch (err) {
      print('Error al decodificar el token: $err');
      return null;
    }
  }

  Future<Map<String, String>?> getCountryStateCityUser() async {
    final userId = await _getUserId();

    if (userId == null) {
      print("No se pudo obtener el ID del usuario.");
      return null;
    }

    try {
      final userData = await _userService.getUserById(userId);

      if (userData != null) {
        final ciudad = userData['ciudad'];
        final estado = userData['estado'];
        final pais = userData['pais'];

        return {
          'pais': pais,
          'estado': estado,
          'ciudad': ciudad,
        };
      } else {
        print('No se encontraron datos del usuario.');
        return null;
      }
    } catch (err) {
      print("Error al obtener los datos del usuario: $err");
      return null;
    }
  }

  Future<bool> _updatePet() async {
    final usuarioId = await _getUserId();

    if (_formKey.currentState?.validate() ?? false) {
      if (!breedList.any((breed) =>
          breed.toLowerCase() == _breedController.text.trim().toLowerCase())) {
        AppOverlay.showOverlay(context, Colors.red,
            "Por favor selecciona una raza válida de la lista");
        return false;
      }

      int agePet = int.parse(_ageController.text);

      print('Updating pet with size: $selectedSize');
      print('Updating pet with temperament: $selectedTemperament');

      try {
        String mainImage;
        List<String> mediaImages = [];
        bool hasNewImages = _selectedImages.any((image) => image != null);

        // Procesar imágenes
        if (hasNewImages) {
          showLoadingOverlay();

          // Filtrar solo las imágenes no nulas
          List<File> imagesToUpload = _selectedImages
              .where((image) => image != null)
              .map((image) => image!)
              .toList();

          // Subir nuevas imágenes
          List<String> uploadedUrls = await uploadImagesDio(imagesToUpload);

          if (uploadedUrls.isEmpty) {
            setState(() => _error = 'Error al subir imágenes.');
            AppOverlay.showOverlay(
                context, Colors.red, "Error al subir imágenes");
            hideLoadingOverlay();
            return false;
          }

          // Construir la lista final de imágenes combinando existentes y nuevas
          List<String> finalImageUrls = [];

          // Primero procesar las imágenes existentes
          for (int i = 0; i < _existingImageUrls.length; i++) {
            // Si hay una nueva imagen en esta posición, usar la nueva
            if (i < _selectedImages.length && _selectedImages[i] != null) {
              // La nueva imagen estará en uploadedUrls en el mismo orden
              final newImageIndex = _selectedImages
                  .sublist(0, i)
                  .where((img) => img != null)
                  .length;
              if (newImageIndex < uploadedUrls.length) {
                finalImageUrls.add(uploadedUrls[newImageIndex]);
              }
            } else {
              // Mantener la imagen existente
              finalImageUrls.add(_existingImageUrls[i]);
            }
          }

          // Agregar cualquier imagen nueva que esté más allá de las existentes
          int newImagesAdded = _selectedImages
              .sublist(0, _existingImageUrls.length)
              .where((img) => img != null)
              .length;

          for (int i = newImagesAdded; i < uploadedUrls.length; i++) {
            if (i < uploadedUrls.length) {
              finalImageUrls.add(uploadedUrls[i]);
            }
          }

          // Asignar mainImage y mediaImages
          if (finalImageUrls.isNotEmpty) {
            mainImage = finalImageUrls[0];
            if (finalImageUrls.length > 1) {
              mediaImages.addAll(finalImageUrls.sublist(1));
            }
          } else {
            mainImage = "";
          }
        } else {
          // No hay imágenes nuevas, usar todas las existentes
          if (_existingImageUrls.isNotEmpty) {
            mainImage = _existingImageUrls[0];
            if (_existingImageUrls.length > 1) {
              mediaImages.addAll(_existingImageUrls.sublist(1));
            }
          } else {
            mainImage = "";
          }
        }

        showLoadingOverlay();
        String breedText = _breedController.text.toLowerCase();
        String gender = (selectedGender ?? 'No definido aún').toLowerCase();

        final locationData = await getCountryStateCityUser();

        String ciudad = locationData?['ciudad'] ?? 'Ciudad desconocida';
        String estado = locationData?['estado'] ?? 'Estado desconocido';
        String pais = locationData?['pais'] ?? 'País desconocido';

        final currentSize = selectedSize;
        final currentTemperament = selectedTemperament;

        final success = await _petService.editPet(
          _petId!,
          mainImage,
          _nameController.text,
          breedText,
          'perro',
          _colorController.text,
          currentSize ?? 'Tamaño desconocido',
          agePet,
          gender,
          _hasPedigree,
          vaccines,
          currentTemperament ?? 'Temperamento desconocido',
          usuarioId ?? 'Usuario desconocido',
          mediaImages,
          pais,
          estado,
          ciudad,
        );

        if (success) {
          // Actualizar las URLs de imágenes existentes con las nuevas
          setState(() {
            if (hasNewImages) {
              _existingImageUrls = [mainImage, ...mediaImages];
            }
            _selectedImages = [
              null,
              null,
              null,
              null
            ]; // Resetear imágenes seleccionadas
          });

          AppOverlay.showOverlay(
              context, Colors.green, "Mascota actualizada con éxito");
          hideLoadingOverlay();

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
          return true;
        } else {
          setState(() => _error = 'Error al actualizar la mascota.');
          AppOverlay.showOverlay(
              context, Colors.red, "Error al actualizar la mascota");
          hideLoadingOverlay();
          return false;
        }
      } on SocketException catch (_) {
        setState(() =>
            _error = 'Error de conexión. Verifica tu conexión a internet.');
        AppOverlay.showOverlay(
            context, Colors.red, "Verifica tu conexión a internet.");
        hideLoadingOverlay();
        return false;
      } catch (err) {
        setState(() => _error = 'Error al actualizar la mascota: $err');
        AppOverlay.showOverlay(
            context, Colors.red, "Error al actualizar la mascota: $err");
        hideLoadingOverlay();
        return false;
      }
    }
    return false;
  }
}

class FixedHeightFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final double height;
  final TextStyle? style;
  final bool enabled;

  FixedHeightFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.height = 70,
    this.style,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FixedHeightFormField> createState() => _FixedHeightFormFieldState();
}

class _FixedHeightFormFieldState extends State<FixedHeightFormField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_errorText != null && widget.controller.text.isNotEmpty) {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: TextFormField(
        controller: widget.controller,
        style: widget.style ?? const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: _errorText,
          counterText: '',
          enabled: widget.enabled,
        ),
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: (value) {
          if (widget.validator != null) {
            final error = widget.validator!(value);
            setState(() {
              _errorText = error;
            });
            return error;
          }
          return null;
        },
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
          if (_errorText != null) {
            setState(() {
              _errorText = null;
            });
          }
        },
      ),
    );
  }
}

class FixedHeightDropdownField<T> extends StatefulWidget {
  final T? value;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final double height;
  final bool enabled;

  FixedHeightDropdownField({
    Key? key,
    required this.value,
    required this.labelText,
    required this.items,
    this.onChanged,
    this.validator,
    this.height = 70,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FixedHeightDropdownField<T>> createState() =>
      _FixedHeightDropdownFieldState<T>();
}

class _FixedHeightDropdownFieldState<T>
    extends State<FixedHeightDropdownField<T>> {
  String? _errorText;
  T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  // In _FixedHeightDropdownFieldState class:
  @override
  void didUpdateWidget(FixedHeightDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update current value if the widget's value changes
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: DropdownButtonFormField<T>(
        value: _currentValue,
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: _errorText,
        ),
        items: widget.items,
        onChanged: widget.enabled
            ? (T? newValue) {
                setState(() {
                  _currentValue = newValue;
                  _errorText = null;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(newValue);
                }
              }
            : null,
        validator: (value) {
          if (widget.validator != null) {
            final error = widget.validator!(value);
            setState(() {
              _errorText = error;
            });
            return error;
          }
          return null;
        },
      ),
    );
  }
}
