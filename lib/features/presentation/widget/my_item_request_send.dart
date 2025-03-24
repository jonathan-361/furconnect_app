import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/widget/overlays/loading_overlay.dart';

class MyItemRequestSend extends StatefulWidget {
  final Map<String, dynamic> petData;
  final deleteButton;
  final String requestId;
  final RequestService requestService;
  final VoidCallback onDelete;

  const MyItemRequestSend({
    super.key,
    required this.petData,
    required this.deleteButton,
    required this.requestId,
    required this.requestService,
    required this.onDelete,
  });

  @override
  State<MyItemRequestSend> createState() => _MyItemRequestSendState();
}

class _MyItemRequestSendState extends State<MyItemRequestSend> {
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
                        _formatWord(
                            widget.petData['nombre'] ?? 'Nombre no disponible'),
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
                    _formatWord(widget.petData['raza']),
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
                          text: widget.deleteButton,
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
        onTap: () {
          context.pushNamed('petCardHome', extra: {
            'petData': widget.petData,
            'source': 'requestSend',
            'requestId': widget.requestId,
            'onDelete': widget.onDelete,
          });
        },
      ),
    );
  }

  void _deleteRequest(BuildContext context) async {
    try {
      widget.onDelete();
      await widget.requestService.deleteRequest(widget.requestId);
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
      child: widget.petData['imagen'] != null &&
              widget.petData['imagen']!.isNotEmpty
          ? Image.network(
              widget.petData['imagen']!.trim(),
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
    Color buttonColor = Colors.red,
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
