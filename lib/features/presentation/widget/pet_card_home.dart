import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/send_request.dart';
import 'package:furconnect/features/presentation/widget/request_button.dart';
import 'package:furconnect/features/presentation/widget/receive_button.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class PetCardHome extends StatefulWidget {
  final Map<String, dynamic> petData;
  final String source;
  final String requestId;
  final Function onDelete;

  const PetCardHome({
    super.key,
    required this.petData,
    required this.source,
    required this.requestId,
    required this.onDelete,
  });

  @override
  State<PetCardHome> createState() => _PetCardHomeState();
}

class _PetCardHomeState extends State<PetCardHome> {
  bool _hasSentRequest = false;
  bool _isLoading = false;

  String ciudad = '';
  String estado = '';

  @override
  void initState() {
    super.initState();
    _checkIfRequestExists();
  }

  Future<void> _checkIfRequestExists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _getUserId();
      if (userId == null) {
        print('UserId es nulo');
        return;
      }

      final pets = await PetService(ApiService(), LoginService(ApiService()))
          .getPetsByOwner(userId);

      final hasSamePet = pets.any((pet) => pet['_id'] == widget.petData['_id']);

      final sentRequests =
          await RequestService(ApiService(), LoginService(ApiService()))
              .getSendRequest();
      final receivedRequests =
          await RequestService(ApiService(), LoginService(ApiService()))
              .getReceiveRequest();

      final hasAcceptedRequest =
          [...sentRequests, ...receivedRequests].any((request) {
        final mascotaSolicitadoId = request['mascota_solicitado_id']?['_id'];
        final mascotaSolicitanteId = request['mascota_solicitante_id']?['_id'];
        final usuarioSolicitadoId = request['usuario_solicitado_id'];
        final usuarioSolicitanteId = request['usuario_solicitante_id'];
        final estado = request['estado'];

        return (mascotaSolicitadoId == widget.petData['_id'] ||
                mascotaSolicitanteId == widget.petData['_id']) &&
            (usuarioSolicitadoId == userId || usuarioSolicitanteId == userId) &&
            (estado == 'aceptado' || estado == 'pendiente');
      });

      setState(() {
        _hasSentRequest = hasAcceptedRequest || hasSamePet;
      });

      print('¿Existe una solicitud? $hasAcceptedRequest');
      print('¿Tiene la misma mascota? $hasSamePet');
    } catch (err) {
      print('Error al verificar solicitudes: $err');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    print('ID de la mascota: ${widget.petData['_id']}');

    if (widget.petData['usuario_id'] is Map) {
      print(
          'ID del usuario de la mascota: ${widget.petData['usuario_id']['_id']}');
    } else {
      print('usuario_id no es un mapa, es: ${widget.petData['usuario_id']}');
    }

    if (widget.petData['usuario_id'] is Map) {
      ciudad = widget.petData['usuario_id']['ciudad'] ?? 'Ciudad no disponible';
      estado = widget.petData['usuario_id']['estado'] ?? 'Estado no disponible';
    } else {
      ciudad = widget.petData['ciudad'] ?? 'Ciudad no disponible';
      estado = widget.petData['estado'] ?? 'Estado no disponible';
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(''),
          ),
          body: Stack(
            children: [
              _showPetImages(context),
              LayoutBuilder(
                builder: (context, constraints) {
                  double imageHeight = MediaQuery.of(context).size.height / 1.8;
                  return SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(top: imageHeight),
                        child: Card(
                          margin: const EdgeInsets.all(0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                      top: 24,
                                      bottom: 0,
                                    ),
                                    child: Text(
                                      _formatWord(widget.petData['nombre']),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0,
                                  ),
                                  SizedBox(
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        top: 26,
                                        bottom: 0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        widget.petData['sexo'] == 'macho'
                                            ? Icons.male
                                            : Icons.female,
                                        color: Colors.brown.shade800,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 0,
                                  bottom: 24,
                                ),
                                child: Text(
                                  _formatWord(widget.petData['raza']),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        const Color.fromARGB(255, 68, 68, 68),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Vive en: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatWord('$ciudad, $estado'),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Edad: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatWord(
                                          "${widget.petData['edad']} años"),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Color: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatWord(widget.petData['color']),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Pedigree: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatWord(widget.petData['pedigree']
                                          ? "Sí"
                                          : "No"),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Tamaño: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatWord(widget.petData['tamaño']),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Temperamento: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatWord(
                                          widget.petData['temperamento']),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 4,
                                  bottom: 80,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vacunas: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        widget.petData['vacunas'] == null ||
                                                widget
                                                    .petData['vacunas'].isEmpty
                                            ? 'No tiene vacunas'
                                            : _formatWord(widget
                                                .petData['vacunas']
                                                .join(', ')),
                                        style: TextStyle(fontSize: 18),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (widget.source == 'home')
                SendRequest(
                  petData: widget.petData,
                  hasSentRequest: _hasSentRequest,
                  onRequestSent: () {
                    setState(() {
                      _hasSentRequest = true;
                    });
                  },
                ),
              if (widget.source == 'requestSend')
                RequestButton(
                  petData: widget.petData,
                  requestId: widget.requestId,
                  onDelete: widget.onDelete,
                ),
              if (widget.source == 'requestReceive')
                ReceiveButton(
                  petData: widget.petData,
                  requestId: widget.requestId,
                  onDelete: widget.onDelete,
                ),
            ],
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }

  Widget _showPetImages(BuildContext context) {
    print(widget.requestId);
    List<String> images = [];

    if (widget.petData['imagen'] != null &&
        widget.petData['imagen'].isNotEmpty) {
      images.add(widget.petData['imagen']);
    }

    if (widget.petData['media'] != null && widget.petData['media'].isNotEmpty) {
      images.addAll(List<String>.from(widget.petData['media']));
    }

    if (images.isEmpty) {
      images.add('assets/images/placeholder/item_pet_placeholder.jpg');
    }

    final PageController controller = PageController();

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.6,
      child: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.6,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/placeholder/item_pet_placeholder.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.6,
                fit: BoxFit.cover,
              );
            },
          );
        },
      ),
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

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
