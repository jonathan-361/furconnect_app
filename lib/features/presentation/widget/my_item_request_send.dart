import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/overlay.dart';
import 'package:furconnect/features/presentation/widget/loading_overlay.dart';

class MyItemRequestSend extends StatelessWidget {
  final String nombre;
  final String raza;
  final String? imagenUrl;
  final deleteButton;
  final String requestId;
  final RequestService requestService;
  final VoidCallback onDelete;

  const MyItemRequestSend({
    super.key,
    required this.nombre,
    required this.raza,
    required this.imagenUrl,
    required this.deleteButton,
    required this.requestId,
    required this.requestService,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Row(
          children: [
            _buildImage(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatWord(nombre),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveFontSize(context, 20),
                          fontFamily: 'Nunito',
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatWord(raza),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _getResponsiveFontSize(context, 16),
                      fontFamily: 'Nunito',
                      color: const Color.fromARGB(255, 134, 128, 126),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          text: deleteButton,
                          onPressed: () {
                            _deleteRequest(context);
                          },
                          buttonColor: Colors.red,
                          buttonSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {},
      ),
    );
  }

  void _deleteRequest(BuildContext context) async {
    try {
      onDelete();
      await requestService.deleteRequest(requestId);
      AppOverlay.showOverlay(
          context, Colors.green, "Solicitud eliminada éxitosamente");
    } catch (err) {
      AppOverlay.showOverlay(
          context, Colors.red, "Error al eliminar la solicitud: $err");
    }
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imagenUrl != null && imagenUrl!.isNotEmpty
          ? Image.network(
              imagenUrl!.trim(),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'assets/images/placeholder/pet_placeholder.jpg',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color buttonColor = Colors.blue,
    double buttonSize = 13,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: buttonSize,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return baseSize * 0.9;
    } else if (screenWidth < 340) {
      return baseSize * 0.8;
    }
    return baseSize;
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
