import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/user_service.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class SendRequest extends StatefulWidget {
  final Map<String, dynamic> petData;
  final bool hasSentRequest;
  final VoidCallback onRequestSent;
  const SendRequest({
    super.key,
    required this.petData,
    required this.hasSentRequest,
    required this.onRequestSent,
  });

  @override
  _SendRequestState createState() => _SendRequestState();
}

class _SendRequestState extends State<SendRequest> {
  final RequestService _requestService =
      RequestService(ApiService(), LoginService(ApiService()));

  String? selectedPet;
  String? selectedPetImage;
  String? selectedPetId;

  bool _isLoading = false;
  bool _hasSentRequest = false;

  @override
  void initState() {
    super.initState();
    _hasSentRequest = widget.hasSentRequest;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: widget.hasSentRequest ? null : _showRequestDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.hasSentRequest
                    ? Colors.grey
                    : Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.hasSentRequest
                    ? 'Solicitud enviada'
                    : 'Enviar solicitud',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'RobotoR',
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
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

  Future<List<dynamic>> _getPets(String userId, String raza) async {
    final petService = PetService(ApiService(), LoginService(ApiService()));
    try {
      final allPets = await petService.getPetsByOwner(userId);
      return allPets.where((pet) => pet['raza'] == raza).toList();
    } catch (err) {
      print('Error al obtener las mascotas: $err');
      return [];
    }
  }

  void _showRequestDialog() async {
    showLoadingOverlay();
    final userId = await _getUserId();
    if (userId == null) {
      hideLoadingOverlay();
      return;
    }

    // Obtener la raza de la mascota
    final raza = widget.petData['raza'];
    if (raza == null) {
      print('No se encontró la raza en petData');
      hideLoadingOverlay();
      return;
    }

    if (widget.petData.containsKey('raza')) {
      print('Raza de la mascota: ${widget.petData['raza']}');
    } else {
      print('No se encontró la raza en petData');
    }

    final pets = await _getPets(userId, raza);
    if (pets.isEmpty) {
      hideLoadingOverlay();
      AppOverlay.showOverlay(
          context, Colors.orange, "No tienes mascotas de la raza $raza");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Seleccione a su mascota',
                style: TextStyle(fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedPet,
                    hint: const Text("Selecciona una mascota"),
                    items: pets.map((pet) {
                      return DropdownMenuItem<String>(
                        value: pet['nombre'],
                        child: Text(pet['nombre']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPet = newValue;
                        final selectedPetData = pets.firstWhere(
                          (pet) => pet['nombre'] == newValue,
                          orElse: () => {},
                        );
                        selectedPetImage = selectedPetData['imagen'];
                        selectedPetId = selectedPetData['_id'];
                      });
                    },
                  ),
                  if (selectedPetImage != null && selectedPetImage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          selectedPetImage!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    hideLoadingOverlay();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedPet != null && selectedPetId != null) {
                      Navigator.of(context).pop();
                      _addRequest(selectedPetId!);
                    }
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addRequest(String petId) async {
    final myPetId = petId;
    final myUserId = await _getUserId() ?? '';
    final requestUserId = widget.petData['usuario_id']['_id'] ?? '';
    final requestPetId = widget.petData['_id'];

    print('Mi ID de usuario: $myUserId');
    print('ID de mi mascota seleccionada: $myPetId');

    try {
      final success = await _requestService.addRequest(
        myPetId,
        myUserId,
        requestPetId,
        requestUserId,
        'pendiente',
      );

      if (mounted) {
        if (success) {
          widget.onRequestSent(); // Esto actualiza el estado en PetCardHome
          hideLoadingOverlay();
          AppOverlay.showOverlay(
              context, Colors.green, "Solicitud mandada con éxito");
        } else {
          hideLoadingOverlay();
          AppOverlay.showOverlay(
              context, Colors.red, "Error al mandar la solicitud");
        }
      }
    } catch (err) {
      if (mounted) {
        hideLoadingOverlay();
        AppOverlay.showOverlay(
            context, Colors.red, "Error al mandar la solicitud: $err");
      }
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
}
