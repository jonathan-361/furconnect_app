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
  List<dynamic> filteredPets = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  double _previousScrollOffset = 0.0;
  final double _scrollThreshold = 300.0;

  Set<String> activeFilters = {};
  Map<String, bool> _filters = {};

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

  void _loadPets() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newPets = await widget.petService.getPets(currentPage, 10);
      if (!mounted) return;
      setState(() {
        pets.addAll(newPets);
        filteredPets = _applyFilters(pets);
        isLoading = false;
        if (newPets.length < 10) {
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

  List<dynamic> _applyFilters(List<dynamic> pets) {
    if (activeFilters.isEmpty) return pets;

    List<dynamic> filteredPets = pets.where((pet) {
      String sexo = pet['sexo'].toLowerCase();

      // Filtrar por sexo
      if (activeFilters.contains('macho') && sexo != 'macho') {
        print('Sexo: ${pet['sexo']}');
        return false;
      }
      if (activeFilters.contains('hembra') && sexo != 'hembra') {
        print('Sexo: ${pet['sexo']}');
        return false;
      }

      // Filtrar por edad
      int edad = pet['edad'] is int
          ? pet['edad']
          : int.tryParse(pet['edad'].toString()) ?? 0;

      if (activeFilters.contains('1 a 3 años') && (edad < 1 || edad > 3)) {
        return false;
      }
      if (activeFilters.contains('4 a 7 años') && (edad < 4 || edad > 7)) {
        return false;
      }
      if (activeFilters.contains('8 a 10 años') && (edad < 8 || edad > 10)) {
        return false;
      }
      if (activeFilters.contains('11 a 15 años') && (edad < 11 || edad > 15)) {
        return false;
      }
      if (activeFilters.contains('+15 años') && edad < 16) {
        return false;
      }

      // Filtrar por pedigree
      if (activeFilters.contains('pedigree') && pet['pedigree'] != true)
        return false;

      // Filtrar por raza
      if (activeFilters.any((filter) => filter.startsWith('raza:'))) {
        String raza = pet['raza']?.toLowerCase() ?? '';
        if (!activeFilters.contains('raza:$raza')) {
          return false;
        }
      }

      return true;
    }).toList();

    return filteredPets;
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
      filteredPets.clear();
      currentPage = 1;
      hasMore = true;
    });
    _loadPets();
  }

  void _updateFilter(String filter, bool isSelected) {
    setState(() {
      if (isSelected) {
        activeFilters.add(filter);
      } else {
        activeFilters.remove(filter);
      }
      print('Filtros activos: $activeFilters');
      filteredPets = _applyFilters(pets);
    });
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
          if (breed.isNotEmpty && !uniqueBreeds.contains(breed)) {
            print('Nombre de la mascota: $breed');
            uniqueBreeds.add(breed);
          }
        }
      } catch (err) {
        print("Error al obtener mascotas: $err");
      }
    } else {
      print("No se pudo obtener el ID del usuario.");
    }
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
                              selected: activeFilters.contains('macho'),
                              onSelected: (bool value) {
                                _updateFilter('macho', value);
                                getPetsBreed();
                              },
                            ),
                            FilterChip(
                              label: Text('Hembra'),
                              selected: activeFilters.contains('hembra'),
                              onSelected: (bool value) {
                                _updateFilter('hembra', value);
                              },
                            ),
                            FilterChip(
                              label: Text('1 a 3 años'),
                              selected: activeFilters.contains('1 a 3 años'),
                              onSelected: (bool value) {
                                _updateFilter('1 a 3 años', value);
                              },
                            ),
                            FilterChip(
                              label: Text('4 a 7 años'),
                              selected: activeFilters.contains('4 a 7 años'),
                              onSelected: (bool value) {
                                _updateFilter('4 a 7 años', value);
                              },
                            ),
                            FilterChip(
                              label: Text('8 a 10 años'),
                              selected: activeFilters.contains('8 a 10 años'),
                              onSelected: (bool value) {
                                _updateFilter('8 a 10 años', value);
                              },
                            ),
                            FilterChip(
                              label: Text('11 a 15 años'),
                              selected: activeFilters.contains('11 a 15 años'),
                              onSelected: (bool value) {
                                _updateFilter('11 a 15 años', value);
                              },
                            ),
                            FilterChip(
                              label: Text('+15 años'),
                              selected: activeFilters.contains('+15 años'),
                              onSelected: (bool value) {
                                _updateFilter('+15 años', value);
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
                    onPressed: () async {
                      _showFilterModal(context);
                    },
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
                  itemCount: filteredPets.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < filteredPets.length) {
                      final petData = filteredPets[index];
                      return _buildPetCard(
                        imageUrl: petData['media']?.isNotEmpty ?? false
                            ? petData['media'][0]
                            : null,
                        name: petData['nombre'],
                        onTap: () => context.pushNamed('petCardHome', extra: {
                          'petData': petData,
                          'source': 'home',
                          'requestId': petData['requestId'] ?? '',
                          'onDelete': () {
                            print('codigo innecesariamente necesario');
                          },
                        }),
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

  Widget _buildPetCard({
    required String? imageUrl,
    required String name,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) async {
    final userId = await _getUserId();
    if (userId != null) {
      try {
        final petsList = await widget.petService.getPetsByOwner(userId);

        Set<String> uniqueBreeds = Set<String>();
        for (var pet in petsList) {
          String breed = pet['raza'] ?? '';
          if (breed.isNotEmpty) {
            uniqueBreeds.add(breed.toLowerCase());
          }
        }

        List<String> breeds = uniqueBreeds.toList();
        Map<String, bool> breedSelections = {};

        // Inicializar el estado de los filtros de raza
        for (var breed in breeds) {
          breedSelections[breed] = activeFilters.contains('raza:$breed');
        }

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
                  breeds: breeds,
                  initialSelections: breedSelections,
                  onApplyFilters: (updatedSelections) {
                    setState(() {
                      // Limpiar los filtros de raza anteriores
                      activeFilters
                          .removeWhere((filter) => filter.startsWith('raza:'));

                      // Aplicar los nuevos filtros de raza
                      updatedSelections.forEach((breed, isSelected) {
                        if (isSelected) {
                          activeFilters.add('raza:$breed');
                        }
                      });

                      // Aplicar los filtros
                      filteredPets = _applyFilters(pets);
                    });
                  },
                );
              },
            );
          },
        );
      } catch (err) {
        print("Error al obtener razas: $err");
      }
    } else {
      print("No se pudo obtener el ID del usuario.");
    }
  }
}

class FilterModal extends StatefulWidget {
  final List<String> breeds;
  final Map<String, bool> initialSelections;
  final Function(Map<String, bool>) onApplyFilters;

  FilterModal({
    required this.breeds,
    required this.initialSelections,
    required this.onApplyFilters,
  });

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late Map<String, bool> breedSelections;
  bool onlyVaccinated = false;
  bool onlyPedigree = false;

  @override
  void initState() {
    super.initState();
    breedSelections = Map.from(widget.initialSelections);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filtros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text('Solo mascotas vacunadas'),
                    value: onlyVaccinated,
                    onChanged: (value) {
                      setState(() {
                        onlyVaccinated = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Solo mascotas con pedigree'),
                    value: onlyPedigree,
                    onChanged: (value) {
                      setState(() {
                        onlyPedigree = value ?? false;
                      });
                    },
                  ),
                  ...widget.breeds.map((breed) {
                    return CheckboxListTile(
                      title: Text(breed),
                      value: breedSelections[breed],
                      onChanged: (value) {
                        setState(() {
                          breedSelections[breed] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(breedSelections);
              Navigator.pop(context);
            },
            child: Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
}
