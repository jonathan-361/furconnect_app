import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ItemPet extends StatelessWidget {
  final Map<String, dynamic> petData;
  final VoidCallback? onPetDeleted;
  final String navigateTo;

  const ItemPet({
    super.key,
    required this.petData,
    required this.navigateTo,
    required this.onPetDeleted,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _loadPetImage(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatWord(petData['nombre']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveFontSize(context, 18),
                          fontFamily: 'Nunito',
                          color: Colors.brown.shade700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          petData['sexo'].toLowerCase() == "macho"
                              ? Icons.male
                              : Icons.female,
                          color: Colors.brown.shade800,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(context, 'Raza:', petData['raza']),
                  _buildInfoRow(context, 'Edad:', petData['edad'].toString()),
                  _buildInfoRow(context, 'Tamaño:', petData['tamaño']),
                  _buildInfoRow(context, 'Color:', petData['color']),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          final shouldRefresh = await context.pushNamed(
            'petCard',
            extra: {
              'petData': petData,
              'onPetUpdated': onPetDeleted,
            },
          );
          if (shouldRefresh == true) {
            onPetDeleted?.call();
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              fontFamily: 'Inter',
              color: Colors.brown.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatWord(value),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Colors.brown.shade900,
                ),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 300) {
      return baseSize * 0.8;
    } else if (screenWidth < 280) {
      return baseSize * 0.7;
    }
    return baseSize;
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  Widget _loadPetImage() {
    if (petData['media'] is List && petData['imagen'].isNotEmpty) {
      String imageUrl = petData['imagen'].toString().trim();
      return Image.network(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder/item_pet_placeholder.jpg',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        'assets/images/placeholder/item_pet_placeholder.jpg',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }
}
