import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/user_service.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class ReceiveButton extends StatefulWidget {
  final Map<String, dynamic> petData;
  final String requestId;
  final Function onDelete;

  const ReceiveButton(
      {super.key,
      required this.petData,
      required this.requestId,
      required this.onDelete});

  @override
  _ReceiveButtonState createState() => _ReceiveButtonState();
}

class _ReceiveButtonState extends State<ReceiveButton> {
  final RequestService _requestService =
      RequestService(ApiService(), LoginService(ApiService()));

  String? selectedPet;
  String? selectedPetImage;
  String? selectedPetId;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Alinea los botones al centro
              children: [
                // Primer botón
                ElevatedButton(
                  onPressed: () {
                    print('Request ID: ${widget.requestId}');
                    _acceptRequest(context);
                    // Agrega la acción para el primer botón aquí
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(140, 50), // Tamaño del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'RobotoR',
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Espacio entre los botones
                // Segundo botón
                ElevatedButton(
                  onPressed: () {
                    print('Second button pressed!');
                    _rejectRequest(context);
                    // Agrega la acción para el segundo botón aquí
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(140, 50), // Tamaño del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Rechazar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'RobotoR',
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

  Future<void> _acceptRequest(BuildContext context) async {
    showLoadingOverlay();
    try {
      await _requestService.acceptRequest(widget.requestId);
      widget.onDelete();
      Navigator.pop(context); // Retrocede a la página anterior
      AppOverlay.showOverlay(
          context, Colors.green, "Solicitud aceptada éxitosamente");
    } catch (err) {
      AppOverlay.showOverlay(
          context, Colors.red, "Error al aceptar la solicitud: $err");
    } finally {
      hideLoadingOverlay();
    }
  }

  Future<void> _rejectRequest(BuildContext context) async {
    showLoadingOverlay();
    try {
      await _requestService.rejectRequest(widget.requestId);
      widget.onDelete();
      Navigator.pop(context); // Retrocede a la página anterior
      AppOverlay.showOverlay(
          context, Colors.red, "Solicitud rechazada éxitosamente");
    } catch (err) {
      AppOverlay.showOverlay(
          context, Colors.red, "Error al rechazar la solicitud: $err");
    } finally {
      hideLoadingOverlay();
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
