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
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _loadPetImage(),
            ),
            const SizedBox(width: 6),
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
                          fontSize: _getResponsiveFontSize(context, 16),
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        alignment: Alignment.center,
                        child: Icon(
                          petData['sexo'].toLowerCase() == "macho"
                              ? Icons.male
                              : Icons.female,
                          color: const Color.fromARGB(220, 79, 42, 15),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
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
          final shouldRefresh =
              await context.pushNamed('petCard', extra: petData);
          if (shouldRefresh == true) {
            onPetDeleted?.call();
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 14),
            fontFamily: 'Inter',
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
              ),
              softWrap: true,
            ),
          ),
        ),
      ],
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
    if (petData['media'] is List && petData['media'].isNotEmpty) {
      String imageUrl = petData['media'][0].toString().trim();
      return Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder/item_pet_placeholder.jpeg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        'assets/images/placeholder/item_pet_placeholder.jpeg',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
  }
}
