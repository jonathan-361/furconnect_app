import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';

class PetCard extends StatefulWidget {
  final Map<String, dynamic> petData;
  final Function()? onPetUpdated;

  const PetCard({
    super.key,
    required this.petData,
    required this.onPetUpdated,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  late Map<String, dynamic> _currentPetData;
  late PetService _petService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPetData = Map<String, dynamic>.from(widget.petData);
    final apiService = ApiService();
    final loginService = LoginService(apiService);
    _petService = PetService(apiService, loginService);
  }

  // Method to fetch updated pet data
  Future<void> _refreshPetData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPetData =
          await _petService.getPetById(_currentPetData['_id']);

      if (updatedPetData != null) {
        setState(() {
          _currentPetData = updatedPetData;
        });

        // Call the onPetUpdated callback to notify parent widgets
        widget.onPetUpdated?.call();
      }
    } catch (e) {
      AppOverlay.showOverlay(
          context, Colors.red, "Error al cargar los datos de la mascota");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF894936),
        title: Text(
          _formatWord(_currentPetData['nombre']),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFC48253)))
                  : _showPetImages(),
              SizedBox(height: 16),
              _infoCard(),
              SizedBox(height: 16),
              _actionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showPetImages() {
    List<String> images = [];

    if (_currentPetData['imagen'] != null &&
        _currentPetData['imagen'].isNotEmpty) {
      images.add(_currentPetData['imagen']);
    }

    if (_currentPetData['media'] != null &&
        _currentPetData['media'].isNotEmpty) {
      images.addAll(List<String>.from(_currentPetData['media']));
    }

    if (images.isEmpty) {
      images.add('assets/images/placeholder/item_pet_placeholder.jpg');
    }

    final PageController controller = PageController();

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[index],
                  width: 200,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder/item_pet_placeholder.jpg',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: controller,
          count: images.length,
          effect: ExpandingDotsEffect(
            activeDotColor: Color(0xFFC48253),
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }

  Widget _infoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(
              Icons.pets,
              "Tipo",
              _formatWord(_currentPetData['tipo']),
            ),
            _infoRow(
              Icons.category,
              "Raza",
              _formatWord(_currentPetData['raza']),
            ),
            _infoRow(
              Icons.cake,
              "Edad",
              "${_currentPetData['edad']} años",
            ),
            _infoRow(
              Icons.color_lens,
              "Color",
              _formatWord(_currentPetData['color']),
            ),
            _infoRow(Icons.check_circle, "Pedigree",
                _currentPetData['pedigree'] ? "Sí" : "No"),
            _infoRow(
              Icons.height,
              "Tamaño",
              _formatWord(_currentPetData['tamaño']),
            ),
            _infoRow(
              Icons.flash_on,
              "Tipo",
              _formatWord(_currentPetData['temperamento']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFC48253)),
          SizedBox(width: 10),
          Text("$label:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final result =
                await context.push('/editPet', extra: _currentPetData);
            if (result == true) {
              await _refreshPetData();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFC48253),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            "Editar Mascota",
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () =>
              _showDeleteConfirmationDialog(context, _currentPetData['_id']),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF894936),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child:
              Text("Eliminar Mascota", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String petId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta mascota?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deletePet(context, petId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePet(BuildContext context, String petId) async {
    final dio = Dio();
    try {
      final String? mainImageUrl = _currentPetData['imagen'];
      print(mainImageUrl);
      final List<String> mediaImageUrls =
          List<String>.from(_currentPetData['media'] ?? []);
      print(mediaImageUrls);

      Future<void> deleteImageFromCloudinary(String imageUrl) async {
        final publicId = _extractPublicIdFromUrl(imageUrl);
        if (publicId != null) {
          await dio.delete(
            'https://api.cloudinary.com/v1_1/dvt90q1cu/image/destroy',
            queryParameters: {
              'public_id': publicId,
              'api_key': '643382773776643',
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
              'signature': _generateSignature(publicId),
            },
          );
        }
      }

      if (mainImageUrl != null && mainImageUrl.isNotEmpty) {
        await deleteImageFromCloudinary(mainImageUrl);
      }

      for (final imageUrl in mediaImageUrls) {
        if (imageUrl.isNotEmpty) {
          await deleteImageFromCloudinary(imageUrl);
        }
      }

      await _petService.deletePet(petId);
      AppOverlay.showOverlay(
          context, Colors.green, "Mascota eliminada éxitosamente");
      context.pop(true);
    } catch (e) {
      AppOverlay.showOverlay(context, Colors.red,
          "Error al eliminar la mascota, intente nuevamente");
    }
  }

  String? _extractPublicIdFromUrl(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final segments = uri.pathSegments;

    if (segments.length >= 4) {
      print(segments);
      return segments.last.split('.').first;
    }
    return null;
  }

  String _generateSignature(String publicId) {
    final String apiSecret = 'RgipPB2SUXmcxvaJ8DHx-ZNc-fE';

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final Map<String, String> params = {
      'public_id': publicId,
      'timestamp': timestamp,
    };

    final sortedParams = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final String paramString =
        sortedParams.map((entry) => '${entry.key}=${entry.value}').join('&');
    final String signatureBase = '$paramString$apiSecret';
    final bytes = utf8.encode(signatureBase);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
