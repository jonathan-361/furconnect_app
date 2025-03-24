import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:furconnect/features/data/services/api_service.dart';
import 'package:furconnect/features/data/services/login_service.dart';
import 'package:furconnect/features/data/services/user_service.dart';
import 'package:furconnect/features/data/services/pet_service.dart';
import 'package:furconnect/features/data/services/request_service.dart';
import 'package:furconnect/features/presentation/page/home_page/side_bar.dart';
import 'package:furconnect/features/presentation/widget/overlays/overlay.dart';
import 'package:furconnect/features/presentation/page/home_page//app_bar.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final apiService = ApiService();
  final loginService = LoginService(ApiService());
  final userService = UserService(ApiService(), LoginService(ApiService()));
  final petService = PetService(ApiService(), LoginService(ApiService()));

  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: SideBar(),
      body: _HomePageBody(petService: petService),
    );
  }
}

class _HomePageBody extends StatefulWidget {
  final PetService petService;

  const _HomePageBody({required this.petService});

  @override
  __HomePageBodyState createState() => __HomePageBodyState();
}

class __HomePageBodyState extends State<_HomePageBody> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> pets = [];
  List<String> _breeds = [];
  Map<String, bool> _breedSelections = {};
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool onlyVaccinated = false;
  double _previousScrollOffset = 0.0;
  final double _scrollThreshold = 300.0;
  String _raza = '';
  String _sexo = '';

  @override
  void initState() {
    super.initState();
    _loadPets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8.0,
                          children: [
                            FilterChip(
                              label: Text('Macho'),
                              selected: _sexo == 'macho',
                              onSelected: (bool value) {
                                _onSexSelected('macho');
                                getPetsBreed();
                              },
                            ),
                            FilterChip(
                              label: Text('Hembra'),
                              selected: _sexo == 'hembra',
                              onSelected: (bool value) {
                                _onSexSelected('hembra');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ActionChip(
                    avatar: Icon(Icons.filter_list),
                    label: Text('Filtros'),
                    onPressed: () => _showFilterModal(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPets,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: pets.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < pets.length) {
                      final petData = pets[index];
                      return _buildPetCard(
                        petData: petData,
                        context: context,
                      );
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              _scrollController.animateTo(
                0.0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _encodeSpecialCharacters(String input) {
    return input.replaceAllMapped(RegExp(r'[()´{}\sáéíóúÁÉÍÓÚ]'), (match) {
      return Uri.encodeComponent(match.group(0)!);
    });
  }

  void _loadPets() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Obtener las mascotas de la API
      final newPets = await widget.petService.getPetsFilter(
        currentPage,
        10,
        _raza,
        _sexo,
      );

      if (!mounted) return;

      final filteredPets = onlyVaccinated
          ? newPets
              .where(
                  (pet) => pet['vacunas'] != null && pet['vacunas'].isNotEmpty)
              .toList()
          : newPets;

      setState(() {
        pets.addAll(filteredPets);
        isLoading = false;
        if (filteredPets.length < 10) {
          hasMore = false;
        } else {
          currentPage++;
        }
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      AppOverlay.showOverlay(
          context, Colors.red, "Error al cargar la mascota: $err");
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _scrollThreshold) {
      _loadPets();
    }
  }

  Future<void> _refreshPets() async {
    setState(() {
      pets.clear();
      currentPage = 1;
      hasMore = true;
    });
    _loadPets();
  }

  void _onSexSelected(String sexo) {
    setState(() {
      if (_sexo == sexo) {
        _sexo = '';
      } else {
        _sexo = sexo;
      }
    });
    _refreshPets();
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

  Future<void> getPetsBreed() async {
    final userId = await _getUserId();
    if (userId != null) {
      print('ID usuario: $userId');
      try {
        final petsList = await widget.petService.getPetsByOwner(userId);
        Set<String> uniqueBreeds = Set<String>();

        for (var pet in petsList) {
          String breed = pet['raza'] ?? '';

          breed = breed.toLowerCase();
          if (breed.isNotEmpty && !uniqueBreeds.contains(breed)) {
            print('Raza de la mascota: $breed');

            uniqueBreeds.add(breed);
          }
        }
        setState(() {
          _breeds = uniqueBreeds.toList();
        });
      } catch (err) {
        print("Error al obtener mascotas: $err");
      }
    } else {
      print("No se pudo obtener el ID del usuario.");
    }
  }

  Widget _buildPetCard({
    required Map<String, dynamic> petData,
    required BuildContext context,
  }) {
    final String? imageUrl =
        petData['imagen']?.isNotEmpty ?? false ? petData['imagen'] : null;
    final String name = petData['nombre'] ?? 'Sin nombre';
    final String city = petData['usuario_id']['ciudad'] ?? 'Sin ciudad';

    return GestureDetector(
      onTap: () => context.pushNamed(
        'petCardHome',
        extra: {
          'petData': petData,
          'source': 'home',
          'requestId': petData['requestId'] ?? '',
          'onDelete': () {
            print('codigo innecesariamente necesario');
          },
        },
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit:
                                BoxFit.cover, // Mantiene la imagen proporcional
                            width: double
                                .infinity, // Asegura que la imagen ocupe todo el ancho disponible
                            height: double
                                .infinity, // Asegura que la imagen ocupe todo el alto disponible
                            errorBuilder: (context, error, stackTrace) {
                              print('Imagen no válida');
                              return Image.asset(
                                'assets/images/placeholder/pet_placeholder.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/placeholder/pet_placeholder.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2, // Permite 2 líneas antes de cortar
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                  _buildSexIcon(petData['sexo']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSexIcon(String? sexo) {
    if (sexo == 'macho') {
      return Icon(Icons.male, color: Colors.blue);
    } else if (sexo == 'hembra') {
      return Icon(Icons.female, color: Colors.pink);
    } else {
      return Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  void _showFilterModal(BuildContext context) async {
    await getPetsBreed();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.8,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return FilterModal(
              breeds: _breeds,
              initialSelectedBreed: _raza,
              onlyVaccinated: onlyVaccinated,
              onApplyFilters: (selectedBreed, onlyVaccinated) {
                setState(() {
                  _raza = selectedBreed ?? '';
                  this.onlyVaccinated = onlyVaccinated;
                });
                _refreshPets();
              },
            );
          },
        );
      },
    );
  }
}

class FilterModal extends StatefulWidget {
  final List<String> breeds;
  final String? initialSelectedBreed;
  final bool onlyVaccinated;
  final Function(String?, bool) onApplyFilters;

  FilterModal({
    required this.breeds,
    required this.initialSelectedBreed,
    required this.onlyVaccinated,
    required this.onApplyFilters,
  });

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String? selectedBreed; // Almacena la raza seleccionada
  late bool onlyVaccinated;

  @override
  void initState() {
    super.initState();
    selectedBreed =
        widget.initialSelectedBreed; // Inicializar con el valor recibido
    onlyVaccinated = widget.onlyVaccinated;
  }

  // Método para manejar la selección/deselección de razas
  void _onBreedSelected(String breed, bool isSelected) {
    setState(() {
      if (isSelected) {
        // Si se selecciona una raza, deseleccionar cualquier otra raza seleccionada
        selectedBreed = breed;
      } else {
        // Si se deselecciona la raza, establecer selectedBreed en null
        selectedBreed = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          // Contenido desplazable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Checkbox para "Solo mascotas vacunadas"
                  CheckboxListTile(
                    title: Text('Solo mascotas vacunadas'),
                    value: onlyVaccinated,
                    onChanged: (value) {
                      setState(() {
                        onlyVaccinated = value ?? false;
                      });
                    },
                  ),

                  // Lista de razas con CheckboxListTile
                  if (widget.breeds.isNotEmpty) ...[
                    ...widget.breeds.map((breed) {
                      return CheckboxListTile(
                        title: Text(breed),
                        value: selectedBreed ==
                            breed, // Verificar si esta raza está seleccionada
                        onChanged: (value) {
                          _onBreedSelected(
                              breed,
                              value ??
                                  false); // Manejar la selección/deselección
                        },
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),

          // Botón para aplicar filtros
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(selectedBreed,
                  onlyVaccinated); // Pasar la raza seleccionada y el estado de vacunación
              Navigator.pop(context);
            },
            child: Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
}
