import 'package:flutter/material.dart';

class PetCardHome extends StatelessWidget {
  const PetCardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nombre mascota'),
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/placeholder/pet_placeholder.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.6,
              fit: BoxFit.cover,
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
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
                                top: 12,
                                bottom: 0,
                              ),
                              child: Text(
                                _formatWord('nombre mascota'),
                                style: TextStyle(
                                  fontSize: 22,
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
                                  top: 24,
                                  bottom: 12,
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
                            bottom: 12,
                          ),
                          child: Text(
                            _formatWord('raza'),
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
                            top: 2,
                            bottom: 2,
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
                                _formatWord('20 años'),
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 2,
                            bottom: 2,
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
                                _formatWord('rojo'),
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 2,
                            bottom: 2,
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
                                _formatWord('Sí'),
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 2,
                            bottom: 2,
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
                                _formatWord('grande'),
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 2,
                            bottom: 2,
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
                                _formatWord('Alegre'),
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 2,
                            bottom: 2,
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
                                  _formatWord(
                                      'tos, rabia, djsakjjhgfuhgfhhdsajhdsajhdkjhaskjhdkjhakjdkhjhaskjdkjakjdhkjashkjdhajshdkjhsajhdjahskjdhkjashkjdhkjashkjdhkajhdkjkhajsd'),
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
          })
        ],
      ),
    );
  }

  String _formatWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}
