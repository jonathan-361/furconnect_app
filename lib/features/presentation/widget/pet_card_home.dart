import 'package:flutter/material.dart';

import 'package:furconnect/features/presentation/widget/send_request.dart';
import 'package:furconnect/features/presentation/widget/request_button.dart';
import 'package:furconnect/features/presentation/widget/receive_button.dart';

class PetCardHome extends StatelessWidget {
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

  Widget _showPetImages(BuildContext context) {
    print(requestId);
    List<String> images = [];

    if (petData['imagen'] != null && petData['imagen'].isNotEmpty) {
      images.add(petData['imagen']);
    }

    if (petData['media'] != null && petData['media'].isNotEmpty) {
      images.addAll(List<String>.from(petData['media']));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  _formatWord(petData['nombre']),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0,
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
                                    Icons.male,
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
                              _formatWord(petData['raza']),
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color.fromARGB(255, 68, 68, 68),
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
                                  'Edad: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatWord("${petData['edad']} años"),
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
                                  _formatWord(petData['color']),
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
                                  _formatWord(
                                      petData['pedigree'] ? "Sí" : "No"),
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
                                  _formatWord(petData['tamaño']),
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
                                  _formatWord(petData['temperamento']),
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
                                    petData['vacunas'] == null ||
                                            petData['vacunas'].isEmpty
                                        ? 'No tiene vacunas'
                                        : _formatWord(
                                            petData['vacunas'].join(', ')),
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
          if (source == 'home') SendRequest(petData: petData),
          if (source == 'requestSend')
            RequestButton(
              petData: petData,
              requestId: requestId,
              onDelete: onDelete,
            ),
          if (source == 'requestReceive')
            ReceiveButton(
              petData: petData,
              requestId: requestId,
              onDelete: onDelete,
            ),
        ],
      ),
    );
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
