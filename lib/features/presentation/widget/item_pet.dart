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
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 6),
        title: Row(
          children: [
            SizedBox(width: 6),
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
                          fontSize: 16,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Spacer(),
                      Wrap(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(70, 201, 134, 60),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              petData['sexo'].toLowerCase() == "macho"
                                  ? Icons.male
                                  : Icons.female,
                              color: const Color.fromARGB(220, 79, 42, 15),
                              size: 24,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Raza:',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        _formatWord(petData['raza']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edad:',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        int.tryParse(petData['edad']?.toString() ?? '0')
                                ?.toString() ??
                            '0',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tamaño:',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        _formatWord(petData['tamaño']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Color:',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        _formatWord(petData['color']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
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

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
