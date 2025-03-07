import 'package:flutter/material.dart';
import 'package:furconnect/features/data/services/user_service.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/overlay.dart';
import 'package:furconnect/features/presentation/widget/loading_overlay.dart';

class RequestButton extends StatefulWidget {
  final Map<String, dynamic> petData;
  final String requestId;
  final Function onDelete;

  const RequestButton(
      {super.key,
      required this.petData,
      required this.requestId,
      required this.onDelete});

  @override
  _RequestButtonState createState() => _RequestButtonState();
}

class _RequestButtonState extends State<RequestButton> {
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
            child: ElevatedButton(
              onPressed: () {
                print('Request ID: ${widget.requestId}');
                _handleRequestDeletion(widget.requestId, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Eliminar solicitud',
                style: TextStyle(
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

  Future<void> _handleRequestDeletion(
      String requestId, BuildContext context) async {
    showLoadingOverlay();
    try {
      await _requestService.deleteRequest(requestId);
      AppOverlay.showOverlay(
          context, Colors.green, "Solicitud eliminada éxitosamente");

      // Llama a onDelete para recargar las solicitudes en MatchPage
      widget.onDelete();

      // Cierra la pantalla actual después de que onDelete haya terminado
      Navigator.pop(context, true);
    } catch (err) {
      AppOverlay.showOverlay(
          context, Colors.red, "Error al eliminar la solicitud: $err");
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
